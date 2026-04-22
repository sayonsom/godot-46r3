shader_type spatial;
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
