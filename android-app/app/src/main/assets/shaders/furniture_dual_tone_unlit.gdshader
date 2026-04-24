shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded, specular_disabled;

// Non-reflective dual-tone furniture shader. Picks between a top colour and
// a side colour using the surface normal's vertical component so the mesh
// reads as 3D without actually being lit. Companion to
// generated_shaders/furniture_two_tone_lit.gdshader but fully unshaded —
// identical look under any world lighting, useful for flat brand visuals.

uniform vec4 top_color : source_color = vec4(0.92, 0.90, 0.86, 1.0);
uniform vec4 side_color : source_color = vec4(0.68, 0.64, 0.60, 1.0);
uniform vec4 accent_color : source_color = vec4(0.40, 0.36, 0.32, 1.0);
uniform float side_softness : hint_range(0.01, 1.0) = 0.35;
uniform float accent_strength : hint_range(0.0, 1.0) = 0.25;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.15;
uniform float shadow_wrap : hint_range(0.0, 1.0) = 0.20;
uniform float color_brightness : hint_range(0.0, 2.0) = 1.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float alpha_clip : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec3 n = normalize(NORMAL);
    vec3 v = normalize(VIEW);

    // Top vs. side split driven by normal.y. side_softness controls the
    // transition width — small values give a hard paint line, large values
    // blend smoothly.
    float top_mask = smoothstep(
        1.0 - side_softness,
        min(1.0 - side_softness + side_softness, 1.0),
        n.y
    );
    vec3 body = mix(side_color.rgb, top_color.rgb, top_mask);

    // Horizontal side tint for an extra bit of depth between left/right
    // facets. Weighted by accent_strength so developers can zero it out.
    float side_bias = clamp(n.x * 0.5 + 0.5, 0.0, 1.0);
    body = mix(body, accent_color.rgb, (1.0 - top_mask) * accent_strength * side_bias);

    // Wrap term darkens surfaces facing away from the viewer without using
    // any real light source.
    float facing = clamp(dot(n, v), 0.0, 1.0);
    body *= mix(1.0 - shadow_wrap, 1.0, facing);

    // Optional rim highlight in top_color to pop silhouettes.
    float rim = pow(1.0 - facing, 2.4);
    body += top_color.rgb * rim * rim_strength;

    ALBEDO = clamp(body * color_brightness, vec3(0.0), vec3(1.0));
    ALPHA = alpha * top_color.a;

    if (ALPHA < alpha_clip) {
        discard;
    }
}
