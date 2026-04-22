shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform float _WorkflowMode : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D _BaseMap : filter_linear_mipmap, repeat_enable;
uniform vec4 _BaseColor : source_color = vec4(1.0);
uniform float _Cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float _Smoothness : hint_range(0.0, 1.0) = 0.5;
uniform float _SmoothnessTextureChannel : hint_range(0.0, 1.0) = 0.0;
uniform float _Metallic : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D _MetallicGlossMap : filter_linear_mipmap, repeat_enable;
uniform vec4 _SpecColor : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform sampler2D _SpecGlossMap : filter_linear_mipmap, repeat_enable;
uniform bool _SpecularHighlights = true;
uniform bool _EnvironmentReflections = true;
uniform float _BumpScale : hint_range(0.0, 2.0) = 1.0;
uniform sampler2D _BumpMap : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float _Parallax : hint_range(0.005, 0.08) = 0.005;
uniform sampler2D _ParallaxMap : filter_linear_mipmap, repeat_enable;
uniform float _OcclusionStrength : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D _OcclusionMap : filter_linear_mipmap, repeat_enable;
uniform vec4 _EmissionColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D _EmissionMap : filter_linear_mipmap, repeat_enable;
uniform sampler2D _DetailMask : filter_linear_mipmap, repeat_enable;
uniform float _DetailAlbedoMapScale : hint_range(0.0, 2.0) = 1.0;
uniform sampler2D _DetailAlbedoMap : filter_linear_mipmap, repeat_enable;
uniform float _DetailNormalMapScale : hint_range(0.0, 2.0) = 1.0;
uniform sampler2D _DetailNormalMap : hint_normal, filter_linear_mipmap, repeat_enable;
uniform bool _AlphaClip = false;
uniform bool _ReceiveShadows = true;

void fragment() {
    vec2 uv = UV;
    vec4 base = texture(_BaseMap, uv) * _BaseColor;
    float parallax = (texture(_ParallaxMap, uv).r - 0.5) * _Parallax;
    uv += normalize(VIEW).xy * parallax;
    base = texture(_BaseMap, uv) * _BaseColor;

    if (_AlphaClip && base.a < _Cutoff) {
        discard;
    }

    vec4 metallic_gloss = texture(_MetallicGlossMap, uv);
    vec4 spec_gloss = texture(_SpecGlossMap, uv);
    vec3 detail = texture(_DetailAlbedoMap, uv * 2.0).rgb;
    float detail_mask = texture(_DetailMask, uv).r;
    vec3 emission = texture(_EmissionMap, uv).rgb * _EmissionColor.rgb;

    ALBEDO = mix(base.rgb, base.rgb * mix(vec3(1.0), detail * _DetailAlbedoMapScale, detail_mask), 0.4);
    ALPHA = base.a;
    METALLIC = mix(_Metallic, metallic_gloss.r, step(0.5, _WorkflowMode));
    ROUGHNESS = clamp(1.0 - mix(_Smoothness, metallic_gloss.a, _SmoothnessTextureChannel), 0.04, 1.0);
    SPECULAR = _SpecularHighlights ? clamp(dot(mix(_SpecColor.rgb, spec_gloss.rgb, 0.5), vec3(0.333333)), 0.0, 1.0) : 0.0;
    AO = mix(1.0, texture(_OcclusionMap, uv).r, _OcclusionStrength);
    EMISSION = emission + (_EnvironmentReflections ? vec3(0.0) : ALBEDO * 0.08);
    NORMAL_MAP = texture(_BumpMap, uv).rgb;
    NORMAL_MAP_DEPTH = _BumpScale;
}
