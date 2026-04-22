shader_type spatial;
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
