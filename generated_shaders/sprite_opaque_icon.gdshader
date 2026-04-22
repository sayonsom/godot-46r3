shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform sampler2D _MainTex : filter_linear_mipmap, repeat_enable;
uniform float _AlphaCutting : hint_range(0.0, 1.0) = 0.9;
uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 _TexColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float _TextureOpacity : hint_range(0.0, 1.0) = 1.0;
uniform bool _HorizontalFlip = false;
uniform bool _VerticalFlip = false;

vec2 get_flipped_uv(vec2 uv) {
    uv.x = _HorizontalFlip ? 1.0 - uv.x : uv.x;
    uv.y = _VerticalFlip ? 1.0 - uv.y : uv.y;
    return uv;
}

void fragment() {
    vec2 uv = get_flipped_uv(UV);
    vec4 sampled = texture(_MainTex, uv);
    sampled.rgb *= _TexColor.rgb;
    sampled.a *= _TexColor.a;
    vec3 tint_mix = mix(_Color.rgb, sampled.rgb * _Color.rgb, _TextureOpacity);
    float alpha = sampled.a * _Color.a;
    if (alpha < _AlphaCutting) {
        discard;
    }
    ALBEDO = tint_mix;
    ALPHA = alpha;
}
