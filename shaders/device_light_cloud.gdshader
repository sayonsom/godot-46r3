shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.55, 1.0);
uniform vec4 core_color : source_color = vec4(1.0, 0.97, 0.82, 1.0);
uniform float intensity : hint_range(0.0, 5.0) = 1.55;
uniform float density : hint_range(0.5, 6.0) = 2.3;
uniform float core_strength : hint_range(0.0, 3.0) = 1.1;
uniform float vertical_bias : hint_range(-1.0, 1.0) = 0.18;
uniform float pulse_speed : hint_range(0.0, 8.0) = 1.25;
uniform float pulse_strength : hint_range(0.0, 0.3) = 0.055;

float hash12(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 v = normalize(VIEW);
	float facing = clamp(abs(dot(n, v)), 0.0, 1.0);

	// Soft bias so the cloud sits heavier near the fixture and thins downward.
	float up = clamp(n.y * 0.5 + 0.5, 0.0, 1.0);
	float bias = mix(1.0, up, clamp(vertical_bias, 0.0, 1.0));

	float thickness = pow(facing, density) * bias;
	float core = pow(facing, density * 2.4) * core_strength * bias;

	float shimmer = mix(0.95, 1.05, hash12(floor(UV * 10.0) + floor(TIME * 1.8)));
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;

	vec3 color = glow_color.rgb * thickness + core_color.rgb * core;
	float alpha = clamp(thickness * 0.82 + core * 0.55, 0.0, 1.0);
	if (alpha < 0.01) {
		discard;
	}

	ALBEDO = vec3(0.0);
	EMISSION = color * intensity * pulse * shimmer;
	ALPHA = alpha;
}
