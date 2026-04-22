shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _BackgroundColor : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform vec4 _GridColor : source_color = vec4(0.4, 0.4, 0.4, 1.0);
uniform float _GridUnit = 16.0;
uniform float _GridThickness = 1.0;
uniform float _SubGridThickness = 0.5;
uniform float _SubGridDivider = 4.0;
uniform float _GridFinalAlpha = 1.0;
uniform float _GridIndicatorSizeMultiplier = 1.0;
uniform float _GridIndicatorSoftness = 1.0;
uniform vec4 _GridIndicatorColor0 : source_color = vec4(1.0, 0.2, 0.2, 1.0);
uniform vec4 _GridIndicatorColor1 : source_color = vec4(0.2, 0.7, 1.0, 1.0);
uniform float _GridIndicatorGhostAlphaSpeed = 1.0;

float line_mask(float coord, float thickness) {
    float local = abs(fract(coord) - 0.5);
    return 1.0 - smoothstep(0.5 - thickness, 0.5, local);
}

void fragment() {
    vec2 grid_uv = UV * _GridUnit;
    float major = max(line_mask(grid_uv.x, _GridThickness / _GridUnit), line_mask(grid_uv.y, _GridThickness / _GridUnit));
    float minor = max(
        line_mask(grid_uv.x * _SubGridDivider, _SubGridThickness / (_GridUnit * _SubGridDivider)),
        line_mask(grid_uv.y * _SubGridDivider, _SubGridThickness / (_GridUnit * _SubGridDivider))
    );

    float pulse = 0.5 + 0.5 * sin(TIME * _GridIndicatorGhostAlphaSpeed);
    vec2 centered = UV * 2.0 - 1.0;
    float axis_x = exp(-abs(centered.x) * 18.0 / max(_GridIndicatorSizeMultiplier, 0.001));
    float axis_y = exp(-abs(centered.y) * 18.0 / max(_GridIndicatorSizeMultiplier, 0.001));

    vec3 col = _BackgroundColor.rgb;
    col = mix(col, _GridColor.rgb, max(major, minor * 0.5) * _GridFinalAlpha);
    col += _GridIndicatorColor0.rgb * axis_y * pulse * _GridIndicatorSoftness * 0.3;
    col += _GridIndicatorColor1.rgb * axis_x * (1.0 - pulse * 0.5) * _GridIndicatorSoftness * 0.3;
    COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), _BackgroundColor.a);
}
