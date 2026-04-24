# Android Shader Pack — Integration Guide

Revision date: 2026-04-24

This guide supersedes the previous integration doc. It covers both the original generated shader pack **and** the three new non-reflective shaders added in this drop:

- `wall_material_unlit.gdshader`
- `floor_material_unlit.gdshader`
- `furniture_dual_tone_unlit.gdshader`

Everything in this guide has been validated on a Samsung SM-S921B running the reference Godot-hosting Android app.

---

## 1. What's in this drop

| File | Role | Lit? | Render mode |
|---|---|---|---|
| `shaders/wall_material_unlit.gdshader` | Non-reflective wall paint | No | `blend_mix, depth_draw_opaque, cull_back, unshaded, specular_disabled` |
| `shaders/floor_material_unlit.gdshader` | Non-reflective floor colour + optional pattern | No | `blend_mix, depth_draw_opaque, cull_back, unshaded, specular_disabled` |
| `shaders/furniture_dual_tone_unlit.gdshader` | Dual-tone furniture colouring (top / side) | No | `blend_mix, depth_draw_opaque, cull_back, unshaded, specular_disabled` |

All three:
- Are `shader_type spatial` — drop onto any `MeshInstance3D` via `material_override`.
- Never write `METALLIC`, `ROUGHNESS`, or `SPECULAR`. The mesh is visually independent of world lighting, environment, or reflection probes.
- Use colour-space-correct `source_color` hints and ranged floats so developers can drive them from code or the inspector with no surprises.
- Are Android-mobile-renderer safe. No dynamic branching on animated uniforms, no multi-texture lookups, no ALPHA thresholds that require scissor.

---

## 2. Why another pack?

The previous pack (`wall_render_outer`, `floor_pattern`, `furniture_two_tone_lit`) uses lit materials, specular writes, and normal-based lighting. Good for photoreal / SmartThings hero shots, but:

- Varies with scene environment / lights — brand colours drift.
- Floor `reflectivity` uniform still writes `METALLIC` and `SPECULAR`, so you get subtle highlights.
- Furniture pack relies on `diffuse_lambert` — lighting contribution is not 0.

The new unlit pack solves one problem precisely: **give the developer a flat, source-independent way to paint walls, floors, and furniture with stable brand colours**, while still having enough visual depth (vertical gradient, grain, dual-tone) that the 3D scene doesn't look like a flat diagram.

---

## 3. Stable shader IDs

Keep these IDs stable between the native Android layer and the Godot layer. They are the logical contract.

```
wall_render_outer             // legacy lit wall (front)
wall_render_outer_side        // legacy lit wall (side)
floor_pattern                 // legacy lit floor
furniture_two_tone_lit        // legacy lit furniture

wall_material_unlit           // NEW non-reflective wall
floor_material_unlit          // NEW non-reflective floor
furniture_dual_tone_unlit     // NEW non-reflective dual-tone furniture
```

The native Android plugin emits a JSON array of these IDs through the existing `shader_selection_changed` signal; Godot maps ID → `ShaderMaterial` and applies to the appropriate mesh groups.

---

## 4. Uniform reference

All uniforms use the same naming convention as the generated pack: `lower_snake_case`, colour uniforms use `source_color`, scalar uniforms use `hint_range`.

### 4.1 `wall_material_unlit`

| Uniform | Type | Range | Default | Notes |
|---|---|---|---|---|
| `base_color` | `vec4` | `source_color` | `(0.94, 0.93, 0.90, 1.0)` | Primary wall colour. |
| `accent_color` | `vec4` | `source_color` | `(0.78, 0.76, 0.72, 1.0)` | Shown on oblique facets. |
| `accent_mix` | `float` | 0.0–1.0 | `0.35` | How strongly `accent_color` shows. |
| `tone_bias` | `float` | 0.0–1.0 | `0.45` | Width of the side-facing zone. |
| `vertical_gradient` | `float` | 0.0–1.0 | `0.25` | Top-to-bottom darkening. |
| `grain_strength` | `float` | 0.0–0.5 | `0.04` | Static world-space grain. |
| `grain_scale` | `float` | 1.0–128.0 | `32.0` | Grain tile scale. |
| `ambient_darken` | `float` | 0.0–0.6 | `0.18` | Base darkening at bottom. |
| `alpha` | `float` | 0.0–1.0 | `1.0` | Final opacity. |

Recommended production ranges:
- `accent_mix` 0.2–0.4
- `vertical_gradient` 0.15–0.35
- `grain_strength` 0.02–0.06

### 4.2 `floor_material_unlit`

| Uniform | Type | Range | Default | Notes |
|---|---|---|---|---|
| `base_color` | `vec4` | `source_color` | `(0.90, 0.88, 0.84, 1.0)` | Primary floor colour. |
| `accent_color` | `vec4` | `source_color` | `(0.82, 0.80, 0.76, 1.0)` | Pattern / stripe tint. |
| `pattern_mode` | `int` | 0, 1, 2 | `1` | 0 = none, 1 = checker, 2 = stripes. |
| `pattern_strength` | `float` | 0.0–1.0 | `0.25` | Mix toward `accent_color`. |
| `uv_tiling` | `vec2` | — | `(6.0, 6.0)` | Pattern repetition per UV unit. |
| `uv_offset` | `vec2` | — | `(0.0, 0.0)` | Pattern phase. |
| `edge_vignette` | `float` | 0.0–1.0 | `0.15` | Soft darkening toward room edges. |
| `grain_strength` | `float` | 0.0–0.3 | `0.02` | Static grain. |
| `grain_scale` | `float` | 1.0–256.0 | `64.0` | Grain scale. |
| `alpha` | `float` | 0.0–1.0 | `1.0` | Final opacity. |

Recommended production ranges:
- `pattern_strength` 0.10–0.25 (turn off with `pattern_mode = 0`)
- `edge_vignette` 0.08–0.18
- `uv_tiling` `(4, 4)` to `(10, 10)` depending on room scale

### 4.3 `furniture_dual_tone_unlit`

| Uniform | Type | Range | Default | Notes |
|---|---|---|---|---|
| `top_color` | `vec4` | `source_color` | `(0.92, 0.90, 0.86, 1.0)` | Upward-facing faces. |
| `side_color` | `vec4` | `source_color` | `(0.68, 0.64, 0.60, 1.0)` | Side-facing faces. |
| `accent_color` | `vec4` | `source_color` | `(0.40, 0.36, 0.32, 1.0)` | Optional side accent. |
| `side_softness` | `float` | 0.01–1.0 | `0.35` | Transition width between top/side. |
| `accent_strength` | `float` | 0.0–1.0 | `0.25` | How much accent shows on side. |
| `rim_strength` | `float` | 0.0–1.0 | `0.15` | View-based rim highlight. |
| `shadow_wrap` | `float` | 0.0–1.0 | `0.20` | Darkening of away-facing surfaces. |
| `color_brightness` | `float` | 0.0–2.0 | `1.0` | Global multiplier. |
| `alpha` | `float` | 0.0–1.0 | `1.0` | Final opacity. |
| `alpha_clip` | `float` | 0.0–1.0 | `0.05` | Discard threshold. |

Recommended production ranges:
- `side_softness` 0.3–0.55 for soft dual tone; drop below 0.2 for a hard paint line.
- `accent_strength` 0.15–0.30.
- `rim_strength` 0.10–0.20.

---

## 5. How to wire in Godot

### 5.1 Preloads

```gdscript
const SHADER_WALL_MATERIAL_UNLIT       := preload("res://shaders/wall_material_unlit.gdshader")
const SHADER_FLOOR_MATERIAL_UNLIT      := preload("res://shaders/floor_material_unlit.gdshader")
const SHADER_FURNITURE_DUAL_TONE_UNLIT := preload("res://shaders/furniture_dual_tone_unlit.gdshader")
```

### 5.2 Reference apply routine

See `integration_snippets/apply_unlit_shader_pack.gd` in this bundle for a
complete reference implementation with production-sensible defaults. The shape
is:

```gdscript
func apply_unlit_pack(
    floor_meshes: Array[MeshInstance3D],
    wall_meshes: Array[MeshInstance3D],
    furniture_roots: Array[Node3D],
    room_color_lookup: Callable  # Node3D -> Color
) -> void:
    for floor_node in floor_meshes:
        var base := floor_node_base_color(floor_node) # your own lookup
        var m := ShaderMaterial.new()
        m.shader = SHADER_FLOOR_MATERIAL_UNLIT
        m.set_shader_parameter("base_color", base)
        m.set_shader_parameter("accent_color", base.darkened(0.08))
        m.set_shader_parameter("pattern_mode", 1)
        m.set_shader_parameter("pattern_strength", 0.18)
        m.set_shader_parameter("uv_tiling", Vector2(6.0, 6.0))
        m.set_shader_parameter("edge_vignette", 0.12)
        m.set_shader_parameter("grain_strength", 0.02)
        m.set_shader_parameter("grain_scale", 64.0)
        m.set_shader_parameter("alpha", 1.0)
        floor_node.material_override = m
    # ... walls, furniture similarly — see the snippet for full code.
```

### 5.3 Reverting to lit pack

Cache the prior `material_override` on each furniture root before swapping
(`root.set_meta("furniture_lit_materials", {...})`) so the "off" path can put
them back without reloading the scene. Floors can be restored by re-running
your existing `_render_room_finish(entry, finish_id)`; walls by re-running
`_make_wall_material(is_exterior, tint)`.

---

## 6. Bridging from native Android

Native side (`ShaderHostPlugin` or equivalent) emits `shader_selection_changed`
with a string payload. Godot side handles it:

```gdscript
func _on_shader_selection_changed(payload: String) -> void:
    var id := payload.strip_edges()
    match id:
        "unlit_pack":     _apply_unlit_shader_pack(true)
        "unlit_pack_off": _apply_unlit_shader_pack(false)
        "default":        _apply_unlit_shader_pack(false)
        _:                pass # legacy ids handled elsewhere
```

For a richer API (per-surface selection), pass a JSON payload and branch per ID.
Keep the mapping table in one place so the native Kotlin side and the Godot
side stay in sync.

---

## 7. Android performance notes

All three new shaders are cheaper per-pixel than the legacy lit pack because
there are no lighting loops, no PBR math, and only one texture-free arithmetic
path. Validated on SM-S921B (Exynos 2400) in landscape 1080×2340 at steady 60
FPS under the reference scene.

- Prefer one `ShaderMaterial` instance per visual group (one for floors, one
  for each wall cluster) — do not build a fresh material per mesh per frame.
- Reapply only when selection or theme data changes (same rule as the lit
  pack).
- Keep `grain_strength` modest (< 0.10) to avoid perceptible banding on
  low-gamut panels.

---

## 8. QA checklist for this drop

| Check | Method | Expected |
|---|---|---|
| Shader parses on Godot 4.6 | `godot --headless` load script | `OK` for all 3 files |
| Uniform list matches doc | `shader.get_shader_uniform_list()` | 9 / 10 / 10 |
| No reflection on any surface | Visual, environment changed | No change to appearance |
| On-device FPS | Android profiler | ≥ 60 FPS, no frame spikes on mode swap |
| Revert restores lit look | Toggle `unlit_pack_off` | Scene visually matches pre-swap |

---

## 9. Known good tuning for the reference SmartThings scene

These are the values currently checked into `_apply_unlit_shader_pack` in
`scripts/android_home.gd`. Use as a starting point.

**Walls**
```
accent_mix       0.30
tone_bias        0.40
vertical_gradient 0.22
grain_strength   0.035
grain_scale      28.0
ambient_darken   0.14
```

**Floors**
```
pattern_mode       1        (checker)
pattern_strength   0.18
uv_tiling          (6, 6)
edge_vignette      0.12
grain_strength     0.02
grain_scale        64.0
accent_color       base * 0.92
```

**Furniture**
```
side_softness     0.45
accent_strength   0.22
rim_strength      0.14
shadow_wrap       0.22
color_brightness  1.0
top_color         room_color.lightened(0.22)
side_color        room_color.darkened(0.18)
accent_color      room_color.darkened(0.40)
```

---

## 10. File map in this bundle

```
handover_2026-04-24/
├── README.md
├── shaders/
│   ├── wall_material_unlit.gdshader
│   ├── floor_material_unlit.gdshader
│   └── furniture_dual_tone_unlit.gdshader
├── docs/
│   └── ANDROID_SHADER_PACK_INTEGRATION.md   ← this file
└── integration_snippets/
    └── apply_unlit_shader_pack.gd
```

Drop `shaders/` into `res://shaders/` and the snippet into your controller.
That is the whole integration.
