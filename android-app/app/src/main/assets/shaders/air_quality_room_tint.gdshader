shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_never, unshaded;

uniform vec4 tint_color : source_color = vec4(0.42, 0.82, 0.56, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.62, 0.92, 0.76, 1.0);
uniform float tint_alpha : hint_range(0.0, 1.0) = 0.82;
uniform vec2 source_position = vec2(0.0, 0.0);
uniform float highlight_radius : hint_range(0.0, 6.0) = 1.2;
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.35;
uniform float noise_scale : hint_range(0.0, 8.0) = 1.6;
uniform float noise_strength : hint_range(0.0, 0.25) = 0.06;
uniform float noise_speed : hint_range(0.0, 1.5) = 0.12;

varying vec2 v_local_xz;

float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

float noise2d(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash21(i), hash21(i + vec2(1.0, 0.0)), u.x),
		mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

void vertex() {
	v_local_xz = VERTEX.xz;
}

void fragment() {
	// Gentle brightening around the pin source — keeps the tint interesting without breaking the flat look.
	float dist = length(v_local_xz - source_position);
	float highlight = 1.0 - smoothstep(0.0, max(highlight_radius, 0.001), dist);
	vec3 color = mix(tint_color.rgb, highlight_color.rgb, highlight * highlight_strength);

	// Subtle animated noise — keeps the floor from feeling painted-on but stays almost flat.
	vec2 noise_uv = v_local_xz * noise_scale + vec2(TIME * noise_speed, -TIME * noise_speed * 0.73);
	float n = noise2d(noise_uv);
	color += (n - 0.5) * noise_strength;

	ALBEDO = color;
	ALPHA = tint_alpha;
}
