shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 base = texture(_MainTex, UV);
    vec2 shadow_offset = vec2(0.0125, 0.0125);
    vec4 shadow = texture(_MainTex, UV + shadow_offset);
    vec3 shadow_col = vec3(0.0) * shadow.a * 0.35;
    COLOR = vec4(base.rgb * _Color.rgb + shadow_col, base.a * _Color.a);
}
