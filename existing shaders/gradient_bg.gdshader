shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 color_top : source_color = vec4(0.05, 0.02, 0.15, 1.0);
uniform vec4 color_mid : source_color = vec4(0.02, 0.12, 0.18, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.08, 0.04, 0.20, 1.0);
uniform vec4 accent_color : source_color = vec4(0.0, 0.6, 0.8, 1.0);
uniform float shimmer_speed : hint_range(0.1, 2.0) = 0.4;
uniform float shimmer_intensity : hint_range(0.0, 0.3) = 0.08;
uniform float wave_scale : hint_range(1.0, 20.0) = 6.0;

void fragment() {
    vec2 uv = UV;

    // Three-stop gradient
    vec4 grad;
    if (uv.y < 0.5) {
        grad = mix(color_top, color_mid, uv.y * 2.0);
    } else {
        grad = mix(color_mid, color_bottom, (uv.y - 0.5) * 2.0);
    }

    // Animated shimmer waves
    float wave1 = sin(uv.x * wave_scale + TIME * shimmer_speed) * 0.5 + 0.5;
    float wave2 = sin(uv.y * wave_scale * 1.3 + TIME * shimmer_speed * 0.7 + 2.0) * 0.5 + 0.5;
    float wave3 = sin((uv.x + uv.y) * wave_scale * 0.8 + TIME * shimmer_speed * 1.2) * 0.5 + 0.5;
    float shimmer = wave1 * wave2 * wave3;

    // Radial vignette from center
    float dist = distance(uv, vec2(0.5, 0.4));
    float vignette = 1.0 - smoothstep(0.2, 0.9, dist);

    // Combine gradient + shimmer accent
    vec3 final_color = grad.rgb + accent_color.rgb * shimmer * shimmer_intensity * vignette;

    // Subtle aurora band
    float aurora = sin(uv.x * 12.0 + TIME * 0.3) * sin(uv.y * 8.0 - TIME * 0.2);
    aurora = smoothstep(0.6, 1.0, aurora) * 0.04;
    final_color += vec3(0.1, 0.5, 0.7) * aurora;

    ALBEDO = final_color;
    ALPHA = 1.0;
}
