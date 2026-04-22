shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D _Texture2D : filter_linear_mipmap, repeat_enable;
uniform vec4 _BaseColor : source_color = vec4(1.0);
uniform float _TextureAlpha : hint_range(0.0, 1.0) = 1.0;
uniform vec2 _Tiling = vec2(1.0, 1.0);
uniform vec2 _Offset = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = UV * _Tiling + _Offset;
    vec4 tex = texture(_Texture2D, uv);
    vec3 albedo = mix(_BaseColor.rgb, tex.rgb * _BaseColor.rgb, _TextureAlpha);
    ALBEDO = albedo;
    ALPHA = tex.a * _BaseColor.a;
    METALLIC = 0.0;
    ROUGHNESS = 0.72;
    SPECULAR = 0.2;
}
