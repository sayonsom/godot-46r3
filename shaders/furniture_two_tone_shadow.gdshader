shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded, specular_disabled;

// Two-tone shadow shader for sofa furniture, following the SmartThings VI
// guideline aesthetic: a single brand colour (sourced from the room's floor
// finish) is split into a lit face and a deeper shadow face along a virtual
// light direction, with secondary cues — a top-facing lift and a soft rim
// term — that pull pillows, cushion tops, and rounded corners out of the
// surrounding body without breaking the flat-illustration feel.
//
// Inputs:
//   floor_color        — the room's floor colour. Both lit and shadow tones
//                        are derived from this so the sofa always blends with
//                        the floor underneath it.
//   light_direction    — virtual light direction in world space (auto-
//                        normalized). Drives the lit/shadow split.
//   shadow_strength    — 0..1, how much darker the shadow side is vs. base.
//   highlight_strength — 0..1, how much lighter the lit side is vs. base.
//   shadow_softness    — 0..1, terminator width. 0 = hard paint line. Larger
//                        values let subtle normal variations (cushion seams,
//                        rounded corners) produce visible tone steps inside
//                        both the lit and shadow regions.
//   top_lift           — 0..1, extra highlight strength on upward-facing
//                        surfaces. Reveals pillow tops, cushion tops, and
//                        any horizontal cap as a distinct plane from the
//                        body underneath.
//   rim_strength       — 0..1, view-space fresnel rim. Outlines silhouettes
//                        and corner facets without going to a full outline.
//   rim_power          — falloff sharpness of the rim term.
//   ground_shadow_lift — 0..1, brightens undersides a touch so silhouettes
//                        don't crush into pure shadow against the floor.
//   alpha / alpha_clip — fade and cutout control.

uniform vec4 floor_color : source_color = vec4(0.84, 0.86, 0.92, 1.0);
uniform vec3 light_direction = vec3(-0.50, 0.85, 0.55);
uniform float body_darken : hint_range(0.0, 0.4) = 0.14;
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.40;
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.14;
uniform float shadow_softness : hint_range(0.0, 1.0) = 0.28;
uniform float top_lift : hint_range(0.0, 1.0) = 0.10;
uniform float top_tone_white : hint_range(0.0, 1.0) = 0.65;
uniform float top_lift_falloff : hint_range(0.1, 4.0) = 0.55;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.10;
uniform float rim_power : hint_range(0.5, 6.0) = 2.6;
uniform float ground_shadow_lift : hint_range(0.0, 1.0) = 0.10;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float alpha_clip : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec3 n_world = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    vec3 l = normalize(light_direction);

    // Cosine of angle between surface and light. shadow_softness widens the
    // terminator so curved/rounded surfaces show internal tone variation
    // instead of binary clipping.
    float n_dot_l = dot(n_world, l);
    float lit_mask = smoothstep(-shadow_softness, shadow_softness, n_dot_l);

    vec3 base = floor_color.rgb;
    // Body sits slightly darker than the floor — this is the trick that
    // keeps the silhouette readable on light floors. Without it, a near-
    // white floor pulls every brighter cue (highlight, top, rim) to a
    // no-op and the sofa collapses to a flat blob. Body lit/shadow tones
    // are derived from this darkened body, while cushion tops below lift
    // back toward the floor colour for clean three-tone separation.
    vec3 body_base = base * (1.0 - body_darken);
    vec3 lit_tone = mix(body_base, vec3(1.0), highlight_strength);
    vec3 shadow_tone = body_base * (1.0 - shadow_strength);
    vec3 body = mix(shadow_tone, lit_tone, lit_mask);

    // Top-facing lift — secondary highlight on upward normals. This is the
    // cue that separates pillow tops, cushion tops, and table-top surfaces
    // from the body underneath even when both are inside the lit region.
    // top_tone_white controls the brightness of cushion tops independently
    // from the body's highlight_strength, so cushions can pop while the
    // overall body stays close to the floor palette. top_lift_falloff < 1
    // widens the angular response so even gently-curved pillow surfaces
    // (normals not exactly straight up) still get the lift.
    float top_facing = clamp(n_world.y, 0.0, 1.0);
    float top_response = pow(top_facing, top_lift_falloff);
    vec3 top_tone = mix(base, vec3(1.0), top_tone_white);
    body = mix(body, top_tone, top_response * top_lift);

    // Lift the very bottom faces a hair so undersides don't crush against
    // the contact-shadow plane (lift back toward the darkened body, not
    // the floor colour, so the silhouette stays intact).
    float bottom_facing = clamp(-n_world.y, 0.0, 1.0);
    body = mix(body, body_base, bottom_facing * ground_shadow_lift);

    // View-space rim — surfaces grazing the camera get a soft highlight so
    // corner facets and silhouettes read clearly against the floor.
    vec3 v = normalize(VIEW);
    vec3 n_view = normalize(NORMAL);
    float facing = clamp(dot(n_view, v), 0.0, 1.0);
    float rim = pow(1.0 - facing, rim_power);
    vec3 rim_tone = mix(base, vec3(1.0), 0.55);
    body += rim_tone * rim * rim_strength;

    ALBEDO = clamp(body, vec3(0.0), vec3(1.0));
    ALPHA = alpha * floor_color.a;

    if (ALPHA < alpha_clip) {
        discard;
    }
}
