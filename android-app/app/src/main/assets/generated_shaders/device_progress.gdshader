shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _Color : source_color = vec4(1.0);
uniform bool _ClockWise = true;
uniform float _Rotation : hint_range(-360.0, 360.0) = 0.0;
uniform float _TrimStart : hint_range(0.0, 1.0) = 0.0;
uniform float _Length : hint_range(0.0, 1.0) = 0.75;
uniform float _Offset : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 centered = UV * 2.0 - 1.0;
    float radius = length(centered);
    float angle = atan(centered.y, centered.x) / (PI * 2.0);
    angle = fract(angle + 1.0 + radians(_Rotation) / (PI * 2.0) + _Offset);
    if (!_ClockWise) {
        angle = 1.0 - angle;
    }

    float arc = step(_TrimStart, angle) * step(angle, _TrimStart + _Length);
    float inner = smoothstep(0.52, 0.60, radius);
    float outer = 1.0 - smoothstep(0.78, 0.86, radius);
    float ring = inner * outer;
    COLOR = vec4(_Color.rgb, _Color.a * arc * ring);
}
