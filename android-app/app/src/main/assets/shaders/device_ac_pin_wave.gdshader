shader_type canvas_item;
render_mode blend_mix;

uniform vec4 wave_color : source_color = vec4(0.23, 0.69, 0.93, 0.92);
uniform vec4 glow_color : source_color = vec4(0.52, 0.88, 1.0, 0.34);
uniform float speed : hint_range(0.0, 4.0) = 1.24;
uniform float amplitude : hint_range(0.0, 0.12) = 0.054;
uniform float cycles : hint_range(0.5, 3.0) = 1.28;
uniform float line_thickness : hint_range(0.005, 0.06) = 0.024;
uniform float glow_thickness : hint_range(0.01, 0.12) = 0.068;
uniform float softness : hint_range(0.002, 0.05) = 0.014;
uniform float horizontal_padding : hint_range(0.0, 0.3) = 0.08;
uniform float vertical_center_a : hint_range(0.1, 0.9) = 0.34;
uniform float vertical_center_b : hint_range(0.1, 0.9) = 0.68;

void fragment() {
	vec2 uv = UV;
	float wave_offset = sin((uv.x - 0.5) * TAU * cycles - TIME * speed) * amplitude;
	float wave_a_distance = abs(uv.y - (vertical_center_a + wave_offset));
	float wave_b_distance = abs(uv.y - (vertical_center_b + wave_offset));

	float core_a = 1.0 - smoothstep(line_thickness, line_thickness + softness, wave_a_distance);
	float core_b = 1.0 - smoothstep(line_thickness, line_thickness + softness, wave_b_distance);
	float glow_a = 1.0 - smoothstep(line_thickness, glow_thickness, wave_a_distance);
	float glow_b = 1.0 - smoothstep(line_thickness, glow_thickness, wave_b_distance);

	float edge_fade_left = smoothstep(horizontal_padding - softness, horizontal_padding + softness, uv.x);
	float edge_fade_right = 1.0 - smoothstep(1.0 - horizontal_padding - softness, 1.0 - horizontal_padding + softness, uv.x);
	float horizontal_mask = edge_fade_left * edge_fade_right;

	float core = max(core_a, core_b) * horizontal_mask;
	float glow = max(glow_a, glow_b) * horizontal_mask;

	vec3 color = glow_color.rgb * glow * glow_color.a;
	color = mix(color, wave_color.rgb, core);
	float alpha = clamp(glow * glow_color.a + core * wave_color.a, 0.0, 1.0);
	if (alpha <= 0.001) {
		discard;
	}

	COLOR = vec4(color, alpha);
}
