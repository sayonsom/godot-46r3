shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D _BaseMap : filter_linear_mipmap, repeat_enable;
uniform vec4 _BaseColor : source_color = vec4(1.0);
uniform float _Cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float _Smoothness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 _SpecColor : source_color = vec4(0.5, 0.5, 0.5, 0.5);
uniform sampler2D _SpecGlossMap : filter_linear_mipmap, repeat_enable;
uniform float _SpecularHighlights = 1.0;
uniform sampler2D _BumpMap : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float _BumpScale = 1.0;
uniform vec4 _EmissionColor : source_color = vec4(0.0);
uniform sampler2D _EmissionMap : filter_linear_mipmap, repeat_enable;
uniform bool _AlphaClip = false;
uniform bool _ReceiveShadows = true;

void fragment() {
    vec4 base = texture(_BaseMap, UV) * _BaseColor;
    if (_AlphaClip && base.a < _Cutoff) {
        discard;
    }

    vec4 spec_tex = texture(_SpecGlossMap, UV);
    vec3 emission = texture(_EmissionMap, UV).rgb * _EmissionColor.rgb;
    ALBEDO = base.rgb;
    ALPHA = base.a;
    ROUGHNESS = clamp(1.0 - _Smoothness * max(spec_tex.a, 0.25), 0.04, 1.0);
    SPECULAR = clamp(dot(_SpecColor.rgb * spec_tex.rgb, vec3(0.333333)) * _SpecularHighlights, 0.0, 1.0);
    EMISSION = emission;
    NORMAL_MAP = texture(_BumpMap, UV).rgb;
    NORMAL_MAP_DEPTH = _BumpScale;

    if (!_ReceiveShadows) {
        EMISSION += ALBEDO * 0.2;
    }
}
