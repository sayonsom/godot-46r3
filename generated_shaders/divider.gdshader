shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 _Color2 : source_color = vec4(0.6509434, 0.6509434, 0.6509434, 0.0);
uniform float _AddBrightness : hint_range(0.0, 2.0) = 0.0;
uniform bool _GhostLight = false;
uniform float _GhostLightSpeed : hint_range(0.0, 1.0) = 1.0;
uniform vec4 _GhostLightColor : source_color = vec4(0.25, 0.5056, 1.0, 0.0);

void fragment() {
    float sweep = smoothstep(0.0, 1.0, UV.x);
    vec3 col = mix(_Color.rgb, _Color2.rgb, sweep) + vec3(_AddBrightness);
    if (_GhostLight) {
        float glow = exp(-pow(UV.x - fract(TIME * _GhostLightSpeed), 2.0) * 30.0);
        col += _GhostLightColor.rgb * glow * 0.35;
    }
    COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), max(_Color.a, _Color2.a));
}
