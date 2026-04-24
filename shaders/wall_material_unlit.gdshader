shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded, specular_disabled;

// Non-reflective wall shader. Developer-tunable flat colour with optional
// vertical gradient, subtle grain, and a normal-driven tone so corners read
// without depending on scene lighting. Stable uniform names — keep these
// consistent with the integration guide at docs/ANDROID_SHADER_PACK_INTEGRATION.md.

uniform vec4 base_color : source_color = vec4(0.94, 0.93, 0.90, 1.0);
uniform vec4 accent_color : source_color = vec4(0.78, 0.76, 0.72, 1.0);
uniform float accent_mix : hint_range(0.0, 1.0) = 0.35;
uniform float tone_bias : hint_range(0.0, 1.0) = 0.45;
uniform float vertical_gradient : hint_range(0.0, 1.0) = 0.25;
uniform float grain_strength : hint_range(0.0, 0.5) = 0.04;
uniform float grain_scale : hint_range(1.0, 128.0) = 32.0;
uniform float ambient_darken : hint_range(0.0, 0.6) = 0.18;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

varying vec3 world_pos;

float hash12(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Blend base/accent by how side-facing the fragment is. Flat for walls
    // seen head-on, slightly shifted on oblique facets — gives depth without
    // any real lighting math.
    float side_mask = 1.0 - abs(NORMAL.y);
    float tone = smoothstep(1.0 - tone_bias, 1.0, side_mask);
    vec3 col = mix(base_color.rgb, accent_color.rgb, tone * accent_mix);

    // Optional vertical wash (bottom slightly darker than top).
    float v = clamp(world_pos.y * 0.35 + 0.5, 0.0, 1.0);
    col *= mix(1.0 - ambient_darken, 1.0, mix(1.0, v, vertical_gradient));

    // Subtle stable grain keyed to world position — no animation.
    float g = hash12(floor(world_pos.xz * grain_scale)) - 0.5;
    col += vec3(g) * grain_strength;

    ALBEDO = clamp(col, vec3(0.0), vec3(1.0));
    ALPHA = alpha * base_color.a;
}
