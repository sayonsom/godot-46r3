from __future__ import annotations

import csv
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CSV_DIR = ROOT / "csv_output"
OUT_DIR = ROOT / "generated_shaders"
EXISTING_DIR = ROOT / "existing shaders"


def slugify(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")


def load_summary() -> list[dict[str, str]]:
    with (CSV_DIR / "shader_summary.csv").open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def load_uniforms(csv_name: str) -> list[str]:
    path = CSV_DIR / csv_name
    if not path.exists():
        return []
    with path.open(newline="", encoding="utf-8") as handle:
        return [row["Uniform Name"] for row in csv.DictReader(handle) if row.get("Uniform Name")]


def spatial_texture_shader(extra_tex_color: bool = False) -> str:
    tex_color_uniform = (
        'uniform vec4 _TexColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);\n'
        if extra_tex_color
        else ""
    )
    tex_color_mix = "sampled.rgb *= _TexColor.rgb;\n    sampled.a *= _TexColor.a;" if extra_tex_color else ""
    return f"""shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform float _AlphaCutting : hint_range(0.0, 1.0) = 0.9;
uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
{tex_color_uniform}uniform float _TextureOpacity : hint_range(0.0, 1.0) = 1.0;
uniform bool _HorizontalFlip = false;
uniform bool _VerticalFlip = false;

vec2 get_flipped_uv(vec2 uv) {{
    uv.x = _HorizontalFlip ? 1.0 - uv.x : uv.x;
    uv.y = _VerticalFlip ? 1.0 - uv.y : uv.y;
    return uv;
}}

void fragment() {{
    vec2 uv = get_flipped_uv(UV);
    vec4 sampled = texture(_MainTex, uv);
    {tex_color_mix}
    vec3 tint_mix = mix(_Color.rgb, sampled.rgb * _Color.rgb, _TextureOpacity);
    float alpha = sampled.a * _Color.a;
    if (alpha < _AlphaCutting) {{
        discard;
    }}
    ALBEDO = tint_mix;
    ALPHA = alpha;
}}
"""


def sprite_color_shadow_shader() -> str:
    return """shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 base = texture(_MainTex, UV);
    vec2 shadow_offset = vec2(0.0125, 0.0125);
    vec4 shadow = texture(_MainTex, UV + shadow_offset);
    vec3 shadow_col = vec3(0.0) * shadow.a * 0.35;
    COLOR = vec4(base.rgb * _Color.rgb + shadow_col, base.a * _Color.a);
}
"""


def wall_depth_shader() -> str:
    return """shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, unshaded;

uniform vec3 topColor : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 side1Color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 side2Color : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 lightColor : source_color = vec3(0.0, 0.0, 1.0);

void fragment() {
    float top_mask = smoothstep(0.45, 0.85, NORMAL.y);
    float side_mask = 1.0 - top_mask;
    float side_selector = step(0.0, NORMAL.x);
    vec3 side_col = mix(side1Color, side2Color, side_selector);
    vec3 lit = mix(side_col, topColor, top_mask);
    float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 2.0);
    ALBEDO = lit + lightColor * rim * 0.15;
    ALPHA = 1.0;
}
"""


def simple_lit_overlay_shader() -> str:
    return """shader_type spatial;
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
"""


def heatmap_shader(include_gaussian: bool, include_interest: bool) -> str:
    gaussian_uniforms = ""
    gaussian_logic = "float gaussian_overlay = 0.0;"
    interest_uniforms = ""
    interest_logic = "float interest = 0.0;"
    if include_gaussian:
        gaussian_uniforms = """uniform float _BlendOverlayGaussianCoef : hint_range(0.0, 1.0) = 0.0;
uniform float _BlendOverlayGaussianBase : hint_range(0.0, 1.0) = 0.0;
uniform float _BlendOverlayGaussianOpacity : hint_range(0.0, 1.0) = 0.0;
uniform float _BlendOverlayGaussianRatio : hint_range(0.0, 1.0) = 0.0;
"""
        gaussian_logic = """float gaussian_overlay = exp(-pow(max(radial - _BlendOverlayGaussianBase, 0.0), 2.0) / max(_BlendOverlayGaussianCoef + 0.001, 0.001));
    gaussian_overlay *= _BlendOverlayGaussianOpacity * _BlendOverlayGaussianRatio;"""
    if include_interest:
        interest_uniforms = """uniform vec2 _InterestOpacityRange = vec2(0.0, 0.2);
uniform bool _InterestOpacityUseGaussian = false;
uniform float _InterestOpacityGaussianCoef : hint_range(0.0, 1.0) = 0.0;
uniform float _InterestOpacityRatio : hint_range(0.0, 1.0) = 0.0;
"""
        interest_logic = """float interest = smoothstep(_InterestOpacityRange.x, _InterestOpacityRange.y + 0.0001, radial);
    if (_InterestOpacityUseGaussian) {
        interest = exp(-pow(radial, 2.0) / max(_InterestOpacityGaussianCoef + 0.001, 0.001));
    }
    interest *= _InterestOpacityRatio;"""
    return f"""shader_type spatial;
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
{gaussian_uniforms}{interest_uniforms}
float hash21(vec2 p) {{
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}}

void fragment() {{
    vec2 centered = UV * 2.0 - 1.0;
    float radial = max(length(centered) - _BaseRadius, 0.0);
    float mask = 1.0 - smoothstep(_CutRange.x, max(_CutRange.y, _CutRange.x + 0.0001), radial);
    float dither = hash21(floor(FRAGCOORD.xy)) * _DitheringRadius * 0.05;
    float intensity = clamp(_BaseIntensity + mask + dither, 0.0, 1.0);
    vec3 gradient = texture(_GradientTexture, vec2(intensity, 0.5)).rgb;
    vec3 scene_mix = mix(gradient, vec3(intensity), _BlendColorRatio);
    vec3 overlay_scene = mix(scene_mix, vec3(1.0), _BlendOverlaySceneRatio) * _BlendOverlaySceneOpacity;
    {gaussian_logic}
    {interest_logic}
    vec3 final_color = gradient + overlay_scene + vec3(_BlendOverlayWhiteOpacity + gaussian_overlay + interest);
    ALBEDO = clamp(final_color, vec3(0.0), vec3(1.0));
    ALPHA = clamp(intensity * _BaseOpacity, 0.0, 1.0);
}}
"""


def tmp_sdf_shader(mode: str) -> str:
    face_blend = "float face_alpha = smoothstep(0.5 - edge, 0.5 + edge, sdf);"
    outline_alpha = "float outline_alpha = smoothstep(0.5 - outline_edge, 0.5 + outline_edge, sdf);"
    final_color = "vec4 mixed = mix(_OutlineColor, _FaceColor, face_alpha);"
    if mode == "outline":
        final_color = "vec4 mixed = vec4(_OutlineColor.rgb, _OutlineColor.a * outline_alpha);"
    elif mode == "face":
        final_color = "vec4 mixed = vec4(_FaceColor.rgb, _FaceColor.a * face_alpha);"
    return f"""shader_type spatial;
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

void vertex() {{
    VERTEX.xy += vec2(_VertexOffsetX, _VertexOffsetY);
}}

void fragment() {{
    vec2 uv = UV * vec2(_ScaleX, _ScaleY);
    vec2 texel = vec2(1.0 / max(_TextureWidth, 1.0), 1.0 / max(_TextureHeight, 1.0));
    float sdf = texture(_MainTex, uv).a + _FaceDilate * 0.5;
    float underlay = texture(_MainTex, uv + vec2(_UnderlayOffsetX, _UnderlayOffsetY) * texel).a + _UnderlayDilate * 0.5;
    float edge = max(0.001, 0.5 / max(_GradientScale + _Sharpness, 0.001));
    float outline_edge = edge + _OutlineWidth + _OutlineSoftness;
    {face_blend}
    {outline_alpha}
    float underlay_alpha = smoothstep(0.5 - edge - _UnderlaySoftness, 0.5 + edge + _UnderlaySoftness, underlay);
    {final_color}
    vec4 underlay_col = vec4(_UnderlayColor.rgb, _UnderlayColor.a * underlay_alpha);
    vec4 color = underlay_col + mixed * mixed.a;
    ALBEDO = color.rgb;
    ALPHA = color.a;
}}
"""


def two_tone_canvas_shader(transparent: bool = False, opacity_mode: bool = False) -> str:
    alpha_line = "float alpha = 1.0;" if not transparent and not opacity_mode else "float alpha = mix(_Color.a, _Color2.a, tone);"
    extra_uniform = (
        'uniform float _AddBrightness : hint_range(0.0, 2.0) = 0.0;\n'
        if transparent
        else ""
    )
    bright_line = "mixed += vec3(_AddBrightness);" if transparent else ""
    opacity_line = "alpha *= COLOR.a;" if opacity_mode else ""
    return f"""shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 _Color2 : source_color = vec4(0.6509434, 0.6509434, 0.6509434, 0.0);
{extra_uniform}
void fragment() {{
    float tone = smoothstep(0.15, 0.85, UV.y);
    vec3 mixed = mix(_Color.rgb, _Color2.rgb, tone);
    {bright_line}
    {alpha_line}
    {opacity_line}
    COLOR = vec4(mixed, clamp(alpha, 0.0, 1.0));
}}
"""


def house_texture_lit_shader() -> str:
    return """shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D _Texture2D : filter_linear_mipmap, repeat_enable;
uniform vec4 _BaseColor : source_color = vec4(1.0);
uniform float _TextureAlpha : hint_range(0.0, 1.0) = 1.0;
uniform vec2 _Tiling = vec2(1.0, 1.0);
uniform vec2 _Offset = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = UV * _Tiling + _Offset;
    vec4 tex = texture(_Texture2D, uv);
    vec3 albedo = mix(_BaseColor.rgb, tex.rgb * _BaseColor.rgb, _TextureAlpha);
    ALBEDO = albedo;
    ALPHA = tex.a * _BaseColor.a;
    METALLIC = 0.0;
    ROUGHNESS = 0.72;
    SPECULAR = 0.2;
}
"""


def house_texture_unlit_shader() -> str:
    return """shader_type canvas_item;
render_mode blend_mix;

uniform vec4 _BaseColor : source_color = vec4(1.0);
uniform sampler2D _BaseMap : filter_linear_mipmap, repeat_enable;
uniform vec2 _Tiling = vec2(1.0, 1.0);
uniform vec2 _Offset = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = UV * _Tiling + _Offset;
    vec4 tex = texture(_BaseMap, uv);
    COLOR = vec4(tex.rgb * _BaseColor.rgb, tex.a * _BaseColor.a);
}
"""


def shadow_catcher_shader() -> str:
    return """shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, shadow_to_opacity;

void fragment() {
    ALBEDO = vec3(0.0);
    ALPHA = 1.0;
}
"""


def triplanar_lit_shader() -> str:
    return """shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform sampler2D _BaseMap : filter_linear_mipmap, repeat_enable;
uniform vec4 _BaseColor : source_color = vec4(1.0);
uniform sampler2D _BumpMap : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float _Scale : hint_range(0.0, 3.0) = 1.0;
uniform float _Smoothness : hint_range(0.0, 1.0) = 0.5;
uniform float _Metallic : hint_range(0.0, 1.0) = 0.0;
uniform vec4 _SpecColor : source_color = vec4(0.502, 0.502, 0.502, 1.0);
uniform sampler2D _EmissionMap : filter_linear_mipmap, repeat_enable;
uniform vec4 _EmissionColor : source_color = vec4(0.0);
uniform float _Tilling = 1.0;
uniform float _Blending = 1.0;
uniform float _Hue : hint_range(0.0, 360.0) = 0.0;
uniform float _Saturation : hint_range(0.0, 1.0) = 1.0;
uniform float _Contrast : hint_range(0.0, 1.0) = 1.0;
uniform float _Occlusion = 1.0;

varying vec3 world_pos;
varying vec3 world_normal;

vec3 rotate_hue(vec3 color, float hue_deg) {
    float angle = radians(hue_deg);
    float s = sin(angle);
    float c = cos(angle);
    mat3 hue_rotation = mat3(
        vec3(0.299 + 0.701 * c + 0.168 * s, 0.587 - 0.587 * c + 0.330 * s, 0.114 - 0.114 * c - 0.497 * s),
        vec3(0.299 - 0.299 * c - 0.328 * s, 0.587 + 0.413 * c + 0.035 * s, 0.114 - 0.114 * c + 0.292 * s),
        vec3(0.299 - 0.300 * c + 1.250 * s, 0.587 - 0.588 * c - 1.050 * s, 0.114 + 0.886 * c - 0.203 * s)
    );
    return clamp(hue_rotation * color, vec3(0.0), vec3(1.0));
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_NORMAL_MATRIX * NORMAL));
}

void fragment() {
    vec3 weights = pow(abs(normalize(world_normal)), vec3(max(_Blending, 0.001)));
    weights /= max(dot(weights, vec3(1.0)), 0.0001);

    vec2 uv_x = world_pos.yz * _Tilling;
    vec2 uv_y = world_pos.xz * _Tilling;
    vec2 uv_z = world_pos.xy * _Tilling;

    vec3 x_tex = texture(_BaseMap, uv_x).rgb;
    vec3 y_tex = texture(_BaseMap, uv_y).rgb;
    vec3 z_tex = texture(_BaseMap, uv_z).rgb;

    vec3 albedo = x_tex * weights.x + y_tex * weights.y + z_tex * weights.z;
    albedo *= _BaseColor.rgb;
    albedo = rotate_hue(albedo, _Hue);
    float luma = dot(albedo, vec3(0.299, 0.587, 0.114));
    albedo = mix(vec3(luma), albedo, _Saturation);
    albedo = (albedo - 0.5) * max(_Contrast, 0.001) + 0.5;

    ALBEDO = clamp(albedo, vec3(0.0), vec3(1.0));
    ALPHA = _BaseColor.a;
    METALLIC = _Metallic;
    ROUGHNESS = clamp(1.0 - _Smoothness, 0.04, 1.0);
    SPECULAR = clamp(dot(_SpecColor.rgb, vec3(0.333333)), 0.0, 1.0);
    AO = _Occlusion;
    EMISSION = texture(_EmissionMap, uv_y).rgb * _EmissionColor.rgb;
}
"""


def divider_shader() -> str:
    return """shader_type canvas_item;
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
"""


def edit_mode_grid_shader() -> str:
    return """shader_type canvas_item;
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
"""


def sprite_color_shader(with_flip: bool = False, use_base_names: bool = False) -> str:
    texture_uniform = "_BaseMap" if use_base_names else "_MainTex"
    color_uniform = "_BaseColor" if use_base_names else "_Color"
    tiling_uniforms = ""
    uv_line = "vec2 uv = UV;"
    if use_base_names:
        tiling_uniforms = "uniform vec2 _Tiling = vec2(1.0, 1.0);\nuniform vec2 _Offset = vec2(0.0, 0.0);\n"
        uv_line = "vec2 uv = UV * _Tiling + _Offset;"
    flip_uniform = "uniform bool _HorizontalFlip = false;\n" if with_flip else ""
    flip_line = "uv.x = _HorizontalFlip ? 1.0 - uv.x : uv.x;" if with_flip else ""
    return f"""shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D {texture_uniform} : filter_linear_mipmap, repeat_enable;
uniform vec4 {color_uniform} : source_color = vec4(1.0);
{tiling_uniforms}{flip_uniform}
void fragment() {{
    {uv_line}
    {flip_line}
    vec4 tex = texture({texture_uniform}, uv);
    COLOR = vec4(tex.rgb * {color_uniform}.rgb, tex.a * {color_uniform}.a);
}}
"""


def wall_render_shader(side_variant: bool) -> str:
    wave_axis = "world_pos.x" if side_variant else "world_pos.y"
    normal_mask = "1.0 - abs(NORMAL.x)" if side_variant else "1.0 - abs(NORMAL.y)"
    return f"""shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, unshaded;

uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 _Color2 : source_color = vec4(0.6509434, 0.6509434, 0.6509434, 0.0);
uniform float _LightIntensity : hint_range(0.0, 2.0) = 1.0;
uniform bool _GhostLight = false;
uniform float _GhostLightSpeed : hint_range(0.1, 10.0) = 3.0;
uniform vec4 _GhostLightColor : source_color = vec4(0.25, 0.5056235, 1.0, 0.0);

varying vec3 world_pos;

void vertex() {{
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}}

void fragment() {{
    float tone = smoothstep(0.1, 0.9, {normal_mask});
    vec3 col = mix(_Color.rgb, _Color2.rgb, tone) * _LightIntensity;
    if (_GhostLight) {{
        float pulse = exp(-pow(fract({wave_axis} * 0.35 + TIME * _GhostLightSpeed) - 0.5, 2.0) * 30.0);
        col += _GhostLightColor.rgb * pulse * 0.35;
    }}
    ALBEDO = clamp(col, vec3(0.0), vec3(1.0));
    ALPHA = max(_Color.a, _Color2.a);
}}
"""


def character_lit_shader() -> str:
    return """shader_type spatial;
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
"""


def two_layered_lit_shader() -> str:
    return """shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform vec4 _IconColor : source_color = vec4(0.792, 0.792, 0.792, 0.0);
uniform sampler2D _BGTex : filter_linear_mipmap, repeat_enable;
uniform vec4 _Color : source_color = vec4(0.823, 0.823, 0.823, 0.0);
uniform float _Metallic : hint_range(0.0, 1.0) = 0.3;
uniform float _Glossiness : hint_range(0.0, 1.0) = 0.9;
uniform float _IconMetallic : hint_range(0.0, 1.0) = 0.0;
uniform float _IconGlossiness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 bg = texture(_BGTex, UV);
    vec4 icon = texture(_MainTex, UV);
    float sheen = pow(1.0 - abs(UV.x - 0.5) * 2.0, 4.0);
    vec3 bg_col = bg.rgb * _Color.rgb + sheen * _Glossiness * 0.12;
    vec3 icon_col = icon.rgb * _IconColor.rgb + sheen * _IconGlossiness * 0.08;
    vec3 col = mix(bg_col, icon_col, icon.a);
    COLOR = vec4(col, max(bg.a * _Color.a, icon.a * _IconColor.a));
}
"""


def block_3d_shader() -> str:
    return """shader_type canvas_item;
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
"""


def device_progress_shader() -> str:
    return """shader_type canvas_item;
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
"""


def floor_pattern_shader() -> str:
    return """shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo_color : source_color = vec4(0.88, 0.88, 0.86, 1.0);
uniform sampler2D albedo_texture : filter_linear_mipmap, repeat_enable;
uniform vec2 uv_tilling = vec2(2.0, 2.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform float reflectivity : hint_range(0.0, 1.0) = 0.3;

float checker(vec2 uv) {
    vec2 grid = floor(uv);
    return mod(grid.x + grid.y, 2.0);
}

void fragment() {
    vec2 floor_uv = UV * uv_tilling + uv_offset;
    vec4 tex = texture(albedo_texture, floor_uv);
    float pattern = checker(floor_uv * 4.0);
    vec3 uv_color = mix(albedo_color.rgb * 0.95, albedo_color.rgb * 1.05, pattern);
    vec3 final_color = tex.rgb * uv_color;
    ALBEDO = clamp(final_color, vec3(0.0), vec3(1.0));
    ALPHA = tex.a * albedo_color.a;
    METALLIC = reflectivity * 0.15;
    ROUGHNESS = clamp(1.0 - reflectivity, 0.08, 1.0);
    SPECULAR = reflectivity;
}
"""


def furniture_two_tone_lit_shader() -> str:
    return """shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;

uniform sampler2D source_texture : filter_linear_mipmap, repeat_enable;
uniform vec4 source_tint = vec4(1.0);
uniform float source_brightness : hint_range(0.0, 2.0) = 1.0;
uniform vec4 base_color : source_color = vec4(0.76, 0.72, 0.68, 1.0);
uniform float lambert_lighting : hint_range(0.0, 1.0) = 0.85;
uniform float color_brightness : hint_range(0.0, 2.0) = 1.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float alpha_brightness : hint_range(0.0, 2.0) = 1.0;
uniform bool ghost_effect = false;
uniform float ghost_effect_speed : hint_range(0.0, 10.0) = 1.0;
uniform float alpha_clipping_threshold : hint_range(0.0, 1.0) = 0.05;
uniform vec4 room_color : source_color = vec4(0.92, 0.94, 0.98, 1.0);
uniform float dual_tone_strength : hint_range(0.0, 1.0) = 0.35;
uniform float shadow_darkness : hint_range(0.0, 1.0) = 0.18;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec4 tex = texture(source_texture, UV);
    vec3 lit_base = tex.rgb * source_tint.rgb * source_brightness;
    lit_base *= mix(base_color.rgb, room_color.rgb, 0.18);

    float side_mask = pow(1.0 - max(NORMAL.y, 0.0), 1.2);
    float lambert_mask = mix(1.0 - shadow_darkness, 1.0, lambert_lighting);
    vec3 dual_tone = mix(lit_base, lit_base * (1.0 - shadow_darkness), side_mask * dual_tone_strength);

    if (ghost_effect) {
        float pulse = exp(-pow(fract(world_pos.x * 0.35 + TIME * ghost_effect_speed) - 0.5, 2.0) * 30.0);
        dual_tone += room_color.rgb * pulse * 0.1;
    }

    ALBEDO = clamp(dual_tone * color_brightness * lambert_mask, vec3(0.0), vec3(1.0));
    ALPHA = tex.a * alpha * alpha_brightness;
    ROUGHNESS = 0.92;

    if (ALPHA < alpha_clipping_threshold) {
        discard;
    }
}
"""


TEMPLATES = {
    "floor_pattern.gdshader": floor_pattern_shader,
    "furniture_two_tone_lit.gdshader": furniture_two_tone_lit_shader,
    "sprite_opaque.gdshader": lambda: spatial_texture_shader(False),
    "sprite_opaque_icon.gdshader": lambda: spatial_texture_shader(True),
    "sprite_color_shadow.gdshader": sprite_color_shadow_shader,
    "wall_depth_shader.gdshader": wall_depth_shader,
    "simple_lit_overlay.gdshader": simple_lit_overlay_shader,
    "heatmap_base.gdshader": lambda: heatmap_shader(False, False),
    "heatmap_cover.gdshader": lambda: heatmap_shader(True, True),
    "heatmap_unlit_3d.gdshader": lambda: heatmap_shader(True, True),
    "tmp_sdf_mobile.gdshader": lambda: tmp_sdf_shader("combined"),
    "tmp_sdf_mobile_outline.gdshader": lambda: tmp_sdf_shader("outline"),
    "tmp_sdf_mobile_face.gdshader": lambda: tmp_sdf_shader("face"),
    "two_tone_color_unlit.gdshader": lambda: two_tone_canvas_shader(False, False),
    "two_tone_transparent_color_unlit.gdshader": lambda: two_tone_canvas_shader(True, False),
    "two_tone_color_unlit_opacity.gdshader": lambda: two_tone_canvas_shader(False, True),
    "house_texture_lit.gdshader": house_texture_lit_shader,
    "house_texture_unlit.gdshader": house_texture_unlit_shader,
    "shadow_catcher.gdshader": shadow_catcher_shader,
    "triplanar_lit.gdshader": triplanar_lit_shader,
    "divider.gdshader": divider_shader,
    "edit_mode_grid.gdshader": edit_mode_grid_shader,
    "sprite_color.gdshader": lambda: sprite_color_shader(False, False),
    "wall_render_outer.gdshader": lambda: wall_render_shader(False),
    "wall_render_outer_side.gdshader": lambda: wall_render_shader(True),
    "character_lit.gdshader": character_lit_shader,
    "two_layered_lit.gdshader": two_layered_lit_shader,
    "block_3d.gdshader": block_3d_shader,
    "device_progress.gdshader": device_progress_shader,
    "sprite_icon_unlit.gdshader": lambda: sprite_color_shader(True, False),
}


ALIASES = {
    "Heatmap H Base Stenciled": "heatmap_base.gdshader",
    "Heatmap Unlit 3D H Base": "heatmap_base.gdshader",
    "Heatmap H Cover Stenciled": "heatmap_cover.gdshader",
    "Heatmap Unlit 3D H Cover": "heatmap_cover.gdshader",
    "Heatmap Unlit 3D": "heatmap_unlit_3d.gdshader",
    "Heatmap Base": "heatmap_unlit_3d.gdshader",
    "heatmap_box_stenciled": "heatmap_unlit_3d.gdshader",
    "TMP_SDF-Mobile": "tmp_sdf_mobile.gdshader",
    "TMP_SDF-Mobile-2-Pass-Outline": "tmp_sdf_mobile_outline.gdshader",
    "TMP_SDF-Mobile-2-Pass-Face": "tmp_sdf_mobile_face.gdshader",
    "SpriteOpaque": "sprite_opaque.gdshader",
    "SpriteOpaqueIcon": "sprite_opaque_icon.gdshader",
    "SpriteColorShadow": "sprite_color_shadow.gdshader",
    "WallDepthShader": "wall_depth_shader.gdshader",
    "Simple Lit Overlay": "simple_lit_overlay.gdshader",
    "two_tone_color_unlit": "two_tone_color_unlit.gdshader",
    "two_tone_transparent_color_unlit": "two_tone_transparent_color_unlit.gdshader",
    "two_tone_color_unlit_opacity": "two_tone_color_unlit_opacity.gdshader",
    "house_texture_lit": "house_texture_lit.gdshader",
    "house_texture_unlit": "house_texture_unlit.gdshader",
    "shadow_catcher": "shadow_catcher.gdshader",
    "triplanar_lit": "triplanar_lit.gdshader",
    "divider": "divider.gdshader",
    "edit_mode_grid": "edit_mode_grid.gdshader",
    "sprite_color": "sprite_color.gdshader",
    "wall_render_outer": "wall_render_outer.gdshader",
    "character_lit": "character_lit.gdshader",
    "two_layered_lit": "two_layered_lit.gdshader",
    "block_3d": "block_3d.gdshader",
    "device_progress": "device_progress.gdshader",
    "sprite_color_zwrite": "sprite_color.gdshader",
    "sprite_icon_unlit": "sprite_icon_unlit.gdshader",
    "wall_render_outer_side": "wall_render_outer_side.gdshader",
}


EXTRA_SHADERS = [
    {
        "Shader Name": "floor_pattern",
        "Shader Type": "shader_type spatial",
        "Render Mode": "blend_mix, cull_back, diffuse_burley, specular_schlick_ggx",
        "Uniforms": ["albedo_color", "albedo_texture", "uv_tilling", "uv_offset", "reflectivity"],
        "Target File": "floor_pattern.gdshader",
        "Usage Context": "Floor material tuned for UV tiling, albedo tint, and Android-safe reflectivity.",
    },
    {
        "Shader Name": "furniture_two_tone_lit",
        "Shader Type": "shader_type spatial",
        "Render Mode": "cull_disabled, diffuse_lambert, specular_disabled",
        "Uniforms": [
            "source_texture",
            "source_tint",
            "source_brightness",
            "base_color",
            "lambert_lighting",
            "color_brightness",
            "alpha",
            "alpha_brightness",
            "ghost_effect",
            "ghost_effect_speed",
            "alpha_clipping_threshold",
            "room_color",
            "dual_tone_strength",
            "shadow_darkness",
        ],
        "Target File": "furniture_two_tone_lit.gdshader",
        "Usage Context": "Furniture shader with room-aware dual tone shading for darker faces and low shine.",
    },
]


def build_manifest() -> list[dict[str, object]]:
    manifest: list[dict[str, object]] = []
    for row in load_summary():
        name = row["Shader Name"]
        normalized_csv_name = f"{slugify(name).replace('simple_lit_overlay', 'simple_lit_overlay')}_configurable.csv"
        uniform_map = {
            "Simple Lit Overlay": "Simple_Lit_Overlay_configurable.csv",
            "Heatmap H Base Stenciled": "Heatmap_H_Base_Stenciled_configurable.csv",
            "Heatmap H Cover Stenciled": "Heatmap_H_Cover_Stenciled_configurable.csv",
            "Heatmap Unlit 3D": "Heatmap_Unlit_3D_configurable.csv",
            "Heatmap Unlit 3D H Base": "Heatmap_Unlit_3D_H_Base_configurable.csv",
            "Heatmap Unlit 3D H Cover": "Heatmap_Unlit_3D_H_Cover_configurable.csv",
            "Heatmap Base": "Heatmap_Base_configurable.csv",
            "TMP_SDF-Mobile": "TMP_SDF-Mobile_configurable.csv",
            "TMP_SDF-Mobile-2-Pass-Outline": "TMP_SDF-Mobile-2-Pass-Outline_configurable.csv",
            "TMP_SDF-Mobile-2-Pass-Face": "TMP_SDF-Mobile-2-Pass-Face_configurable.csv",
            "WallDepthShader": "WallDepthShader_configurable.csv",
            "SpriteOpaque": "SpriteOpaque_configurable.csv",
            "SpriteOpaqueIcon": "SpriteOpaqueIcon_configurable.csv",
            "SpriteColorShadow": "SpriteColorShadow_configurable.csv",
            "character_lit": "character_lit_configurable.csv",
        }
        csv_name = uniform_map.get(name, normalized_csv_name)
        manifest.append(
            {
                "name": name,
                "shader_type": row["Shader Type"].replace("shader_type ", ""),
                "render_mode": row["Render Mode"],
                "path": f"res://generated_shaders/{ALIASES[name]}",
                "uniforms": load_uniforms(csv_name),
                "usage_context": row["Usage Context"],
                "source_csv": csv_name if (CSV_DIR / csv_name).exists() else None,
            }
        )

    manifest.extend(
        {
            "name": item["Shader Name"],
            "shader_type": item["Shader Type"].replace("shader_type ", ""),
            "render_mode": item["Render Mode"],
            "path": f"res://generated_shaders/{item['Target File']}",
            "uniforms": item["Uniforms"],
            "usage_context": item["Usage Context"],
            "source_csv": None,
        }
        for item in EXTRA_SHADERS
    )
    return manifest


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def write_readme(manifest: list[dict[str, object]]) -> None:
    lines = [
        "# Android Shader Pack",
        "",
        "Generated from the CSV parameter inventory with Godot 4 compatible shader code.",
        "Several close variants are intentionally merged onto a parent shader file to keep the pack maintainable and Android-friendly.",
        "",
        "## Logical Shader Mapping",
        "",
    ]
    for entry in manifest:
        lines.append(f"- `{entry['name']}` -> `{Path(str(entry['path']).replace('res://generated_shaders/', '')).name}`")
    lines.extend(
        [
            "",
            "## Regeneration",
            "",
            "Run `python3 tools/generate_android_shader_pack.py` from the repository root.",
        ]
    )
    write_text(OUT_DIR / "README.md", "\n".join(lines))


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for filename, builder in TEMPLATES.items():
        write_text(OUT_DIR / filename, builder())

    # Keep the previously shared floor shader synchronized with the new Android-safe version.
    write_text(EXISTING_DIR / "floor_pattern.gdshader", floor_pattern_shader())

    manifest = build_manifest()
    write_text(OUT_DIR / "shader_manifest.json", json.dumps(manifest, indent=2))
    write_readme(manifest)
    print(f"Generated {len(TEMPLATES)} shader files into {OUT_DIR}")


if __name__ == "__main__":
    main()
