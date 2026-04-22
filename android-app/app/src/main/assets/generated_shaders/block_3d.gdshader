shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _BaseColor : source_color = vec4(0.643, 0.643, 0.643, 1.0);
uniform sampler2D _BaseMap : filter_linear_mipmap, repeat_enable;
uniform float _LambertAmount : hint_range(0.0, 1.0) = 0.5;
uniform float _ColorBrightness : hint_range(0.0, 2.0) = 1.0;
uniform float _Color2Darkness : hint_range(0.0, 1.0) = 0.0;
uniform float _AlbedoBrightness : hint_range(0.0, 1.0) = 0.0;
uniform bool _GhostLight = false;
uniform float _GhostLightSpeed : hint_range(0.0, 1.0) = 1.0;
uniform vec4 _GhostLightColor : source_color = vec4(0.25, 0.5056, 1.0, 0.0);
uniform float _Alpha = 1.0;

void fragment() {
    vec4 tex = texture(_BaseMap, UV);
    float tone = mix(1.0 - _Color2Darkness, 1.0, pow(UV.y, max(_LambertAmount, 0.001)));
    vec3 col = tex.rgb * _BaseColor.rgb * _ColorBrightness * tone + vec3(_AlbedoBrightness);
    if (_GhostLight) {
        float glow = exp(-pow(UV.x - fract(TIME * _GhostLightSpeed), 2.0) * 30.0);
        col += _GhostLightColor.rgb * glow * 0.35;
    }
    COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), tex.a * _Alpha);
}
