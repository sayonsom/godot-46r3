shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 pin_color : source_color = vec4(1.0, 0.72, 0.0, 1.0);
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float glow_radius : hint_range(0.0, 1.0) = 0.6;
uniform float active : hint_range(0.0, 1.0) = 0.0;
uniform float hover : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;

    // Base pin color with slight gradient
    vec3 base = pin_color.rgb;
    float gradient = smoothstep(0.0, 1.0, uv.y);
    base = mix(base * 0.7, base * 1.2, gradient);

    // Fresnel-like rim lighting
    float rim = 1.0 - abs(dot(NORMAL, VIEW));
    rim = pow(rim, 3.0);
    vec3 rim_color = pin_color.rgb * 1.5 * rim * 0.4;

    // Pulse glow when active
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    float glow = pulse * pulse_intensity * active;

    // Radial glow from center
    float center = distance(uv, vec2(0.5));
    float radial = 1.0 - smoothstep(0.0, glow_radius, center);
    glow *= radial;

    // Hover highlight
    float hover_boost = hover * 0.2;

    // Combine
    vec3 final_color = base + rim_color + pin_color.rgb * glow * 0.8;
    final_color += vec3(hover_boost);

    ALBEDO = final_color;
    ROUGHNESS = 0.3;
    METALLIC = 0.4;
    EMISSION = pin_color.rgb * (glow * 1.5 + active * 0.3);
    SPECULAR = 0.8;
}
