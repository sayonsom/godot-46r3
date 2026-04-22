shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_never, unshaded;

// Radial floor-tint gradient for an AC room wash.
// The room centre holds `center_temperature` and every wall is treated as
// `wall_temperature` (centre + 1°C). Each floor pixel's temperature is
// interpolated by its normalised distance from the room centre and then
// mapped to the palette below: cool blue (16–22), cosy green (22–24), and
// reddish tones above 26.

uniform float center_temperature = 24.0;
uniform float wall_temperature = 25.0;
uniform vec2 center_position = vec2(0.0, 0.0);
uniform float room_extent : hint_range(0.1, 20.0) = 3.0;
uniform float tint_alpha : hint_range(0.0, 1.0) = 0.88;
uniform float gradient_curve : hint_range(0.3, 3.0) = 1.35;
uniform float noise_scale : hint_range(0.0, 8.0) = 1.6;
uniform float noise_strength : hint_range(0.0, 0.25) = 0.03;
uniform float noise_speed : hint_range(0.0, 1.5) = 0.12;
uniform float noise_temp_jitter : hint_range(0.0, 1.0) = 0.35;
uniform float center_highlight_strength : hint_range(0.0, 0.5) = 0.08;
uniform float center_highlight_radius : hint_range(0.0, 6.0) = 0.8;

// Palette stops. Kept as uniforms so the controller script can retune the
// look without touching the shader.
uniform vec4 deep_cold_color : source_color = vec4(0.08, 0.32, 0.96, 1.0);
uniform vec4 cool_color : source_color = vec4(0.30, 0.78, 1.00, 1.0);
uniform vec4 cozy_color : source_color = vec4(0.28, 0.88, 0.46, 1.0);
uniform vec4 cozy_warm_color : source_color = vec4(0.78, 0.92, 0.34, 1.0);
uniform vec4 warm_color : source_color = vec4(1.00, 0.68, 0.26, 1.0);
uniform vec4 hot_color : source_color = vec4(1.00, 0.32, 0.22, 1.0);
uniform vec4 fever_color : source_color = vec4(0.78, 0.10, 0.14, 1.0);

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

vec3 temperature_to_color(float t) {
	if (t <= 16.0) {
		return deep_cold_color.rgb;
	} else if (t <= 22.0) {
		return mix(deep_cold_color.rgb, cool_color.rgb, (t - 16.0) / 6.0);
	} else if (t <= 23.0) {
		return mix(cool_color.rgb, cozy_color.rgb, t - 22.0);
	} else if (t <= 24.0) {
		return mix(cozy_color.rgb, cozy_warm_color.rgb, t - 23.0);
	} else if (t <= 26.0) {
		return mix(cozy_warm_color.rgb, warm_color.rgb, (t - 24.0) * 0.5);
	} else if (t <= 28.0) {
		return mix(warm_color.rgb, hot_color.rgb, (t - 26.0) * 0.5);
	} else if (t <= 32.0) {
		return mix(hot_color.rgb, fever_color.rgb, (t - 28.0) * 0.25);
	}
	return fever_color.rgb;
}

void vertex() {
	v_local_xz = VERTEX.xz;
}

void fragment() {
	vec2 rel = v_local_xz - center_position;
	float dist = length(rel);
	float ratio = clamp(dist / max(room_extent, 0.001), 0.0, 1.0);
	ratio = pow(ratio, gradient_curve);

	vec2 noise_uv = v_local_xz * noise_scale + vec2(TIME * noise_speed, -TIME * noise_speed * 0.73);
	float n = noise2d(noise_uv);

	float pixel_temp = mix(center_temperature, wall_temperature, ratio)
		+ (n - 0.5) * noise_temp_jitter;
	vec3 color = temperature_to_color(pixel_temp);

	float highlight = 1.0 - smoothstep(0.0, max(center_highlight_radius, 0.001), dist);
	color += vec3(center_highlight_strength) * highlight;
	color += (n - 0.5) * noise_strength;

	ALBEDO = color;
	ALPHA = tint_alpha;
}
