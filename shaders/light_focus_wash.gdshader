shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;

uniform vec4 wash_color : source_color = vec4(0.43, 0.44, 0.47, 0.5);

void fragment() {
	ALBEDO = wash_color.rgb;
	ALPHA = wash_color.a;
}
