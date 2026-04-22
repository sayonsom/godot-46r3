shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

uniform vec4 glow_color : source_color = vec4(1.0, 0.84, 0.45, 1.0);
uniform vec4 core_color : source_color = vec4(1.0, 0.96, 0.76, 1.0);
uniform float intensity : hint_range(0.0, 3.0) = 1.2;
uniform float ellipse : hint_range(0.5, 2.0) = 1.18;
uniform float softness : hint_range(0.8, 4.0) = 2.0;
uniform float core_power : hint_range(2.0, 8.0) = 4.8;
uniform float halo_extent : hint_range(0.9, 1.6) = 1.18;
uniform float alpha_strength : hint_range(0.1, 1.5) = 0.88;
uniform float pulse_strength : hint_range(0.0, 0.5) = 0.04;
uniform float pulse_speed : hint_range(0.0, 8.0) = 2.1;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 centered = UV * 2.0 - 1.0;
	centered.y *= ellipse;

	float distance_to_center = length(centered);
	float halo_mask = 1.0 - smoothstep(0.0, halo_extent, distance_to_center);
	float core_mask = 1.0 - smoothstep(0.0, 0.92, distance_to_center);
	float halo = pow(clamp(halo_mask, 0.0, 1.0), softness);
	float core = pow(clamp(core_mask, 0.0, 1.0), core_power);
	float edge_fade = 1.0 - smoothstep(0.82, 1.0, distance_to_center / max(halo_extent, 0.001));
	halo *= edge_fade;
	core *= edge_fade;
	float shimmer = mix(0.965, 1.015, hash(floor(UV * 14.0) + floor(TIME * 2.0)));
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;

	vec3 color = glow_color.rgb * halo + core_color.rgb * core * 1.32;
	float alpha = clamp((halo * 0.48 + core * 0.28) * alpha_strength, 0.0, 1.0);
	if (alpha < 0.012) {
		discard;
	}

	ALBEDO = color * intensity * pulse * shimmer;
	EMISSION = color * (1.12 + core * 1.65) * intensity * pulse * shimmer;
	ALPHA = alpha;
}
