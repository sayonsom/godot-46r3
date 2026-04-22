shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_opaque;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform float _TextureWidth : hint_range(0.0, 8192.0) = 512.0;
uniform float _TextureHeight : hint_range(0.0, 8192.0) = 512.0;
uniform float _GradientScale : hint_range(0.0, 32.0) = 5.0;
uniform vec4 _FaceColor : source_color = vec4(1.0);
uniform float _FaceDilate : hint_range(-1.0, 1.0) = 0.0;
uniform vec4 _OutlineColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float _OutlineWidth : hint_range(0.0, 1.0) = 0.0;
uniform float _OutlineSoftness : hint_range(0.0, 1.0) = 0.0;
uniform vec4 _UnderlayColor : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float _UnderlayOffsetX : hint_range(-1.0, 1.0) = 0.0;
uniform float _UnderlayOffsetY : hint_range(-1.0, 1.0) = 0.0;
uniform float _UnderlayDilate : hint_range(-1.0, 1.0) = 0.0;
uniform float _UnderlaySoftness : hint_range(0.0, 1.0) = 0.0;
uniform float _WeightNormal = 0.0;
uniform float _WeightBold = 0.5;
uniform float _ScaleRatioA = 1.0;
uniform float _ScaleRatioB = 1.0;
uniform float _ScaleRatioC = 1.0;
uniform float _ScaleX = 1.0;
uniform float _ScaleY = 1.0;
uniform float _PerspectiveFilter : hint_range(0.0, 1.0) = 0.875;
uniform float _Sharpness : hint_range(-1.0, 1.0) = 0.0;
uniform float _VertexOffsetX = 0.0;
uniform float _VertexOffsetY = 0.0;
uniform vec4 _ClipRect = vec4(-32767.0, -32767.0, 32767.0, 32767.0);
uniform float _MaskSoftnessX = 0.0;
uniform float _MaskSoftnessY = 0.0;
uniform float _StencilComp = 8.0;
uniform float _Stencil = 0.0;
uniform float _StencilOp = 0.0;
uniform float _StencilWriteMask = 255.0;
uniform float _StencilReadMask = 255.0;
uniform float _CullMode = 0.0;
uniform float _ColorMask = 15.0;

void vertex() {
    VERTEX.xy += vec2(_VertexOffsetX, _VertexOffsetY);
}

void fragment() {
    vec2 uv = UV * vec2(_ScaleX, _ScaleY);
    vec2 texel = vec2(1.0 / max(_TextureWidth, 1.0), 1.0 / max(_TextureHeight, 1.0));
    float sdf = texture(_MainTex, uv).a + _FaceDilate * 0.5;
    float underlay = texture(_MainTex, uv + vec2(_UnderlayOffsetX, _UnderlayOffsetY) * texel).a + _UnderlayDilate * 0.5;
    float edge = max(0.001, 0.5 / max(_GradientScale + _Sharpness, 0.001));
    float outline_edge = edge + _OutlineWidth + _OutlineSoftness;
    float face_alpha = smoothstep(0.5 - edge, 0.5 + edge, sdf);
    float outline_alpha = smoothstep(0.5 - outline_edge, 0.5 + outline_edge, sdf);
    float underlay_alpha = smoothstep(0.5 - edge - _UnderlaySoftness, 0.5 + edge + _UnderlaySoftness, underlay);
    vec4 mixed = vec4(_OutlineColor.rgb, _OutlineColor.a * outline_alpha);
    vec4 underlay_col = vec4(_UnderlayColor.rgb, _UnderlayColor.a * underlay_alpha);
    vec4 color = underlay_col + mixed * mixed.a;
    ALBEDO = color.rgb;
    ALPHA = color.a;
}
