shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 base_color : source_color = vec4(0.15, 0.15, 0.18, 1.0);
uniform vec4 glow_color : source_color = vec4(0.0, 0.7, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.0;
uniform float glow_width : hint_range(0.01, 0.3) = 0.08;
uniform float pulse_speed : hint_range(0.0, 4.0) = 1.5;
uniform float active : hint_range(0.0, 1.0) = 0.0;
uniform int pattern_type : hint_range(0, 4) = 0;

// Noise function for procedural patterns
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
    vec2 uv = UV;

    // Edge glow: distance from UV edges
    float edge_x = min(uv.x, 1.0 - uv.x);
    float edge_y = min(uv.y, 1.0 - uv.y);
    float edge_dist = min(edge_x, edge_y);
    float edge_glow = 1.0 - smoothstep(0.0, glow_width, edge_dist);

    // Pulse animation when active
    float pulse = 1.0 + sin(TIME * pulse_speed) * 0.3 * active;
    float final_glow = edge_glow * glow_intensity * pulse * active;

    // Floor pattern based on room type
    vec3 pattern_color = base_color.rgb;
    vec2 world_uv = uv * 4.0;

    if (pattern_type == 1) {
        // Wood grain (bedrooms)
        float grain = noise(vec2(world_uv.x * 2.0, world_uv.y * 0.5));
        grain += noise(vec2(world_uv.x * 4.0, world_uv.y * 1.0)) * 0.5;
        grain = grain / 1.5;
        pattern_color = mix(vec3(0.25, 0.16, 0.08), vec3(0.35, 0.22, 0.12), grain);
        // Plank lines
        float plank = abs(fract(world_uv.x * 3.0) - 0.5);
        plank = smoothstep(0.48, 0.5, plank);
        pattern_color = mix(pattern_color, pattern_color * 0.7, plank * 0.3);
    } else if (pattern_type == 2) {
        // Tile grid (kitchen)
        vec2 tile_uv = fract(world_uv * 2.0);
        float grid = step(0.95, tile_uv.x) + step(0.95, tile_uv.y);
        grid = clamp(grid, 0.0, 1.0);
        float tile_var = hash(floor(world_uv * 2.0)) * 0.1;
        pattern_color = mix(vec3(0.85 + tile_var, 0.85 + tile_var, 0.88 + tile_var),
                          vec3(0.6, 0.6, 0.65), grid);
    } else if (pattern_type == 3) {
        // Carpet (living room)
        float carpet = noise(world_uv * 8.0) * 0.5 + noise(world_uv * 16.0) * 0.25;
        carpet += noise(world_uv * 32.0) * 0.125;
        pattern_color = mix(vec3(0.18, 0.2, 0.25), vec3(0.25, 0.28, 0.32), carpet);
    } else if (pattern_type == 4) {
        // Concrete/stone (balconies)
        float stone = noise(world_uv * 3.0);
        stone += noise(world_uv * 6.0) * 0.5;
        stone += noise(world_uv * 12.0) * 0.25;
        stone /= 1.75;
        pattern_color = mix(vec3(0.4, 0.42, 0.44), vec3(0.55, 0.56, 0.58), stone);
    }

    // Combine base pattern + edge glow
    vec3 final_color = pattern_color + glow_color.rgb * final_glow;

    // Subtle ambient brightness in center when active
    float center_dist = distance(uv, vec2(0.5));
    float center_glow = (1.0 - smoothstep(0.0, 0.5, center_dist)) * 0.15 * active;
    final_color += glow_color.rgb * center_glow;

    ALBEDO = final_color;
    ROUGHNESS = 0.7;
    METALLIC = 0.05;
    EMISSION = glow_color.rgb * final_glow * 0.5;
}
