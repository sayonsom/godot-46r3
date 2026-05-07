shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, blend_mix, cull_disabled, specular_disabled;

// Mirrors the Bayer-8 dither used by wall_material_dither_unlit so a pin and the
// see-through wall behind it share the same screen-space transparency pattern.
// Always renders on top (depth_test_disabled) so a wall is never drawn over the
// pin, but the pin itself is half-discarded by the same screen-space mask, so it
// reads as part of the same "transparent" pass.

uniform sampler2D source_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float opacity : hint_range(0.0, 1.0) = 0.6;
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.01;

const float BAYER8[64] = {
     0.0, 32.0,  8.0, 40.0,  2.0, 34.0, 10.0, 42.0,
    48.0, 16.0, 56.0, 24.0, 50.0, 18.0, 58.0, 26.0,
    12.0, 44.0,  4.0, 36.0, 14.0, 46.0,  6.0, 38.0,
    60.0, 28.0, 52.0, 20.0, 62.0, 30.0, 54.0, 22.0,
     3.0, 35.0, 11.0, 43.0,  1.0, 33.0,  9.0, 41.0,
    51.0, 19.0, 59.0, 27.0, 49.0, 17.0, 57.0, 25.0,
    15.0, 47.0,  7.0, 39.0, 13.0, 45.0,  5.0, 37.0,
    63.0, 31.0, 55.0, 23.0, 61.0, 29.0, 53.0, 21.0
};

void vertex() {
    // Billboard towards camera while preserving the node's scale (so Sprite3D
    // pixel_size and PIN_HEIGHT_SCALE still apply).
    mat4 bb = mat4(
        vec4(INV_VIEW_MATRIX[0].xyz * length(MODEL_MATRIX[0].xyz), 0.0),
        vec4(INV_VIEW_MATRIX[1].xyz * length(MODEL_MATRIX[1].xyz), 0.0),
        vec4(INV_VIEW_MATRIX[2].xyz * length(MODEL_MATRIX[2].xyz), 0.0),
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = VIEW_MATRIX * bb;
    MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
    vec4 tex = texture(source_tex, UV);
    if (tex.a < alpha_cut) {
        discard;
    }

    vec2 sp = floor(FRAGCOORD.xy);
    int x = int(mod(sp.x, 8.0));
    int y = int(mod(sp.y, 8.0));
    float threshold = (BAYER8[y * 8 + x] + 0.5) / 64.0;
    if (opacity < threshold) {
        discard;
    }

    ALBEDO = tex.rgb;
    ALPHA = tex.a;
}
