shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, unshaded;

uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 _Color2 : source_color = vec4(0.6509434, 0.6509434, 0.6509434, 0.0);
uniform float _LightIntensity : hint_range(0.0, 2.0) = 1.0;
uniform bool _GhostLight = false;
uniform float _GhostLightSpeed : hint_range(0.1, 10.0) = 3.0;
uniform vec4 _GhostLightColor : source_color = vec4(0.25, 0.5056235, 1.0, 0.0);

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float tone = smoothstep(0.1, 0.9, 1.0 - abs(NORMAL.y));
    vec3 col = mix(_Color.rgb, _Color2.rgb, tone) * _LightIntensity;
    if (_GhostLight) {
        float pulse = exp(-pow(fract(world_pos.y * 0.35 + TIME * _GhostLightSpeed) - 0.5, 2.0) * 30.0);
        col += _GhostLightColor.rgb * pulse * 0.35;
    }
    ALBEDO = clamp(col, vec3(0.0), vec3(1.0));
    ALPHA = max(_Color.a, _Color2.a);
}
