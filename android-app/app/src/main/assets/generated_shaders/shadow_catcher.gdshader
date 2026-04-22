shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, shadow_to_opacity;

void fragment() {
    ALBEDO = vec3(0.0);
    ALPHA = 1.0;
}
