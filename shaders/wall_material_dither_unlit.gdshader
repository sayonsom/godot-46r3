shader_type spatial;
render_mode depth_draw_opaque, cull_back, unshaded, specular_disabled;

// Non-compounding see-through wall shader.
//
// PROBLEM this solves: with classic alpha blending (TRANSPARENCY_ALPHA / blend_mix),
// stacking N walls each at opacity = a yields a final occlusion of (1 - (1-a)^N).
// Furniture seen through 1 wall looks one shade dimmer; seen through 3 walls it
// looks 3 shades dimmer. Edges of walls compound even worse.
//
// HOW this fixes it: we don't use alpha blending at all. Instead, every fragment
// is either fully drawn (ALPHA = 1.0) or `discard`-ed, based on a Bayer dither
// keyed to FRAGCOORD.xy (screen position). Because:
//   * the dither key is screen-space, every wall in the scene uses the SAME
//     "this pixel is on / off" decision at any given screen pixel,
//   * we write to depth (depth_draw_opaque), so the nearest wall locks in the
//     pixel and every subsequent wall behind it is depth-occluded there,
// the final occlusion at any screen pixel is binary (drawn or not). Stacking
// more walls cannot make the scene darker than a single wall does. Furniture
// behind 1, 2, or 8 walls is rendered with identical contrast.
//
// Render modes:
//   depth_draw_opaque  — writes depth (the part that prevents compounding).
//   cull_back          — same culling as the rest of the wall pack.
//   unshaded           — no lighting dependency.
//   specular_disabled  — no reflections; matches the rest of the unlit pack.

uniform vec4 base_color : source_color = vec4(0.94, 0.93, 0.90, 1.0);
uniform vec4 accent_color : source_color = vec4(0.78, 0.76, 0.72, 1.0);
uniform float accent_mix : hint_range(0.0, 1.0) = 0.35;
uniform float tone_bias : hint_range(0.0, 1.0) = 0.45;
uniform float vertical_gradient : hint_range(0.0, 1.0) = 0.25;
uniform float ambient_darken : hint_range(0.0, 0.6) = 0.18;
// `opacity` controls how much of each wall the developer sees. 1.0 is fully
// solid; lower values increase the proportion of `discard`-ed pixels so the
// scene behind shows through. Because the dither is screen-space, the visual
// "see-through" rate stays exactly the same no matter how many walls overlap.
uniform float opacity : hint_range(0.0, 1.0) = 0.6;
// 0 = 4x4 Bayer (coarsest, most visible),
// 1 = 8x8 Bayer (recommended default — fine, still pattern-stable),
// 2 = hashed blue-noise-ish (random per pixel; less coherent but no banding).
uniform int dither_mode : hint_range(0, 2) = 1;

varying vec3 world_pos;

const float BAYER4[16] = {
     0.0,  8.0,  2.0, 10.0,
    12.0,  4.0, 14.0,  6.0,
     3.0, 11.0,  1.0,  9.0,
    15.0,  7.0, 13.0,  5.0
};

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

float hash12(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // FRAGCOORD.xy is window-space (in pixels). Screen-position-keyed threshold
    // is the whole reason this shader doesn't compound — it's identical for
    // every wall fragment that lands on the same screen pixel.
    vec2 sp = floor(FRAGCOORD.xy);
    float threshold;
    if (dither_mode == 0) {
        int x = int(mod(sp.x, 4.0));
        int y = int(mod(sp.y, 4.0));
        threshold = (BAYER4[y * 4 + x] + 0.5) / 16.0;
    } else if (dither_mode == 1) {
        int x = int(mod(sp.x, 8.0));
        int y = int(mod(sp.y, 8.0));
        threshold = (BAYER8[y * 8 + x] + 0.5) / 64.0;
    } else {
        threshold = hash12(sp);
    }

    if (opacity < threshold) {
        discard;
    }

    // Same shading model as wall_material_unlit so this is a drop-in
    // replacement when the developer wants non-compounding see-through.
    float side_mask = 1.0 - abs(NORMAL.y);
    float tone = smoothstep(1.0 - tone_bias, 1.0, side_mask);
    vec3 col = mix(base_color.rgb, accent_color.rgb, tone * accent_mix);

    float v = clamp(world_pos.y * 0.35 + 0.5, 0.0, 1.0);
    col *= mix(1.0 - ambient_darken, 1.0, mix(1.0, v, vertical_gradient));

    ALBEDO = clamp(col, vec3(0.0), vec3(1.0));
    ALPHA = 1.0;
}
