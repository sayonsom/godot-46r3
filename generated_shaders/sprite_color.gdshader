shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform vec4 _Color : source_color = vec4(1.0);

void fragment() {
    vec2 uv = UV;
    
    vec4 tex = texture(_MainTex, uv);
    COLOR = vec4(tex.rgb * _Color.rgb, tex.a * _Color.a);
}
