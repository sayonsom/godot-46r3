shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform vec4 _IconColor : source_color = vec4(0.792, 0.792, 0.792, 0.0);
uniform sampler2D _BGTex : filter_linear_mipmap, repeat_enable;
uniform vec4 _Color : source_color = vec4(0.823, 0.823, 0.823, 0.0);
uniform float _Metallic : hint_range(0.0, 1.0) = 0.3;
uniform float _Glossiness : hint_range(0.0, 1.0) = 0.9;
uniform float _IconMetallic : hint_range(0.0, 1.0) = 0.0;
uniform float _IconGlossiness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 bg = texture(_BGTex, UV);
    vec4 icon = texture(_MainTex, UV);
    float sheen = pow(1.0 - abs(UV.x - 0.5) * 2.0, 4.0);
    vec3 bg_col = bg.rgb * _Color.rgb + sheen * _Glossiness * 0.12;
    vec3 icon_col = icon.rgb * _IconColor.rgb + sheen * _IconGlossiness * 0.08;
    vec3 col = mix(bg_col, icon_col, icon.a);
    COLOR = vec4(col, max(bg.a * _Color.a, icon.a * _IconColor.a));
}
