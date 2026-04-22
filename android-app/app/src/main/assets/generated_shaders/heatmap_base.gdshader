shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, unshaded;

uniform sampler2D _GradientTexture : filter_linear_mipmap, repeat_enable;
uniform float _BaseIntensity : hint_range(0.0, 1.0) = 0.0;
uniform float _DitheringRadius : hint_range(0.0, 1.0) = 0.5;
uniform vec2 _CutRange = vec2(0.0, 0.2);
uniform float _BaseRadius = 0.0;
uniform float _BaseOpacity : hint_range(0.0, 1.0) = 1.0;
uniform float _BlendColorRatio : hint_range(0.0, 1.0) = 0.0;
uniform float _BlendOverlaySceneOpacity : hint_range(0.0, 1.0) = 0.0;
uniform float _BlendOverlaySceneRatio : hint_range(0.0, 1.0) = 0.0;
uniform float _BlendOverlayWhiteOpacity : hint_range(0.0, 1.0) = 0.0;

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 centered = UV * 2.0 - 1.0;
    float radial = max(length(centered) - _BaseRadius, 0.0);
    float mask = 1.0 - smoothstep(_CutRange.x, max(_CutRange.y, _CutRange.x + 0.0001), radial);
    float dither = hash21(floor(FRAGCOORD.xy)) * _DitheringRadius * 0.05;
    float intensity = clamp(_BaseIntensity + mask + dither, 0.0, 1.0);
    vec3 gradient = texture(_GradientTexture, vec2(intensity, 0.5)).rgb;
    vec3 scene_mix = mix(gradient, vec3(intensity), _BlendColorRatio);
    vec3 overlay_scene = mix(scene_mix, vec3(1.0), _BlendOverlaySceneRatio) * _BlendOverlaySceneOpacity;
    float gaussian_overlay = 0.0;
    float interest = 0.0;
    vec3 final_color = gradient + overlay_scene + vec3(_BlendOverlayWhiteOpacity + gaussian_overlay + interest);
    ALBEDO = clamp(final_color, vec3(0.0), vec3(1.0));
    ALPHA = clamp(intensity * _BaseOpacity, 0.0, 1.0);
}
