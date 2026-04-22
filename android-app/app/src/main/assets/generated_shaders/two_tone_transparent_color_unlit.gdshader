shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 _Color2 : source_color = vec4(0.6509434, 0.6509434, 0.6509434, 0.0);
uniform float _AddBrightness : hint_range(0.0, 2.0) = 0.0;

void fragment() {
    float tone = smoothstep(0.15, 0.85, UV.y);
    vec3 mixed = mix(_Color.rgb, _Color2.rgb, tone);
    mixed += vec3(_AddBrightness);
    float alpha = mix(_Color.a, _Color2.a, tone);
    
    COLOR = vec4(mixed, clamp(alpha, 0.0, 1.0));
}
