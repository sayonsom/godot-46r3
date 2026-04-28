# Android Shader Pack Handover — 2026-04-24

Hand this folder to the Android team. It contains everything needed to ship
the three new non-reflective shaders into the existing Godot-backed 3D home
view.

## What's new in this drop

Three hand-authored unlit shaders that give the developer a stable, brand-safe
way to colour walls, floors, and furniture without any lighting dependency:

- `shaders/wall_material_unlit.gdshader`
- `shaders/wall_material_dither_unlit.gdshader` — **non-compounding** see-through wall
- `shaders/floor_material_unlit.gdshader`
- `shaders/furniture_dual_tone_unlit.gdshader`

All three are `shader_type spatial`, fully unshaded, no specular / metallic /
roughness writes. Tested on Samsung SM-S921B, Godot 4.6.2 mobile renderer,
steady 60 FPS.

## Drop-in checklist

1. Copy `shaders/` into your Godot project's `res://shaders/` folder.
2. Paste `integration_snippets/apply_unlit_shader_pack.gd` into your scene
   controller (the one that already owns `_floor_nodes`, `_wall_tint_entries`,
   and `_furniture_roots`).
3. Add a handler for the existing `shader_selection_changed` signal that
   matches payload `"unlit_pack"` → on, `"unlit_pack_off"` / `"default"` →
   off.
4. Read `docs/ANDROID_SHADER_PACK_INTEGRATION.md` for the full uniform
   reference and tuning notes.

## Logical shader IDs (keep stable across native / Godot)

```
wall_material_unlit
wall_material_dither_unlit
floor_material_unlit
furniture_dual_tone_unlit
```

## Contents

```
handover_2026-04-24/
├── README.md                                   ← this file
├── shaders/
│   ├── wall_material_unlit.gdshader
│   ├── wall_material_dither_unlit.gdshader
│   ├── floor_material_unlit.gdshader
│   └── furniture_dual_tone_unlit.gdshader
├── docs/
│   └── ANDROID_SHADER_PACK_INTEGRATION.md      ← full integration guide
└── integration_snippets/
    └── apply_unlit_shader_pack.gd              ← paste into controller
```

## Validation artefacts

Device-captured before/after screenshots from the reference scene live in
the root of the source repo:

- `tmp_unlit_OFF_3d.png` — baseline with default lit pack.
- `tmp_unlit_ON_3d_v2.png` — unlit pack applied with high-contrast preview
  tuning (exaggerated to make the effect unmistakable — not production
  defaults).

Production defaults are what's in `integration_snippets/apply_unlit_shader_pack.gd`.
