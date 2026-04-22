shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _BaseColor : source_color = vec4(1.0);
uniform sampler2D _BaseMap : filter_linear_mipmap, repeat_enable;
uniform vec2 _Tiling = vec2(1.0, 1.0);
uniform vec2 _Offset = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = UV * _Tiling + _Offset;
    vec4 tex = texture(_BaseMap, uv);
    COLOR = vec4(tex.rgb * _BaseColor.rgb, tex.a * _BaseColor.a);
}
