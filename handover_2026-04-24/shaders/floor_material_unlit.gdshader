shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded, specular_disabled;

// Non-reflective floor shader. Tunable flat colour with an optional
// secondary colour blended via a tiled checker or stripe pattern, plus a
// soft radial falloff and a static grain. No METALLIC / SPECULAR / ROUGHNESS
// writes — the floor never reflects anything regardless of environment.

uniform vec4 base_color : source_color = vec4(0.90, 0.88, 0.84, 1.0);
uniform vec4 accent_color : source_color = vec4(0.82, 0.80, 0.76, 1.0);
uniform float pattern_strength : hint_range(0.0, 1.0) = 0.25;
// 0 = none, 1 = checker, 2 = stripes
uniform int pattern_mode : hint_range(0, 2) = 1;
uniform vec2 uv_tiling = vec2(6.0, 6.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform float edge_vignette : hint_range(0.0, 1.0) = 0.15;
uniform float grain_strength : hint_range(0.0, 0.3) = 0.02;
uniform float grain_scale : hint_range(1.0, 256.0) = 64.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

float hash12(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float checker(vec2 uv) {
    vec2 g = floor(uv);
    return mod(g.x + g.y, 2.0);
}

float stripes(vec2 uv) {
    return step(0.5, fract(uv.x));
}

void fragment() {
    vec2 uv = UV * uv_tiling + uv_offset;

    float mask = 0.0;
    if (pattern_mode == 1) {
        mask = checker(uv);
    } else if (pattern_mode == 2) {
        mask = stripes(uv);
    }

    vec3 col = mix(base_color.rgb, accent_color.rgb, mask * pattern_strength);

    // Soft radial vignette towards UV edges to anchor room boundaries.
    vec2 d = UV - vec2(0.5);
    float vig = smoothstep(0.45, 0.75, length(d));
    col *= mix(1.0, 1.0 - edge_vignette, vig);

    // Static position-keyed grain.
    float g = hash12(floor(uv * grain_scale)) - 0.5;
    col += vec3(g) * grain_strength;

    ALBEDO = clamp(col, vec3(0.0), vec3(1.0));
    ALPHA = alpha * base_color.a;
}
