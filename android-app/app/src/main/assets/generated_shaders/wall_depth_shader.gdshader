shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, unshaded;

uniform vec3 topColor : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 side1Color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 side2Color : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 lightColor : source_color = vec3(0.0, 0.0, 1.0);

void fragment() {
    float top_mask = smoothstep(0.45, 0.85, NORMAL.y);
    float side_mask = 1.0 - top_mask;
    float side_selector = step(0.0, NORMAL.x);
    vec3 side_col = mix(side1Color, side2Color, side_selector);
    vec3 lit = mix(side_col, topColor, top_mask);
    float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 2.0);
    ALBEDO = lit + lightColor * rim * 0.15;
    ALPHA = 1.0;
}
