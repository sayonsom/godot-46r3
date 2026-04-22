shader_type spatial;
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
