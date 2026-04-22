# Android Shader Pack Integration Guide

This guide explains how to use the generated Godot shader pack from any native Android app.

## Important Boundary

These generated shader files are Godot shader assets (`.gdshader`), not raw Android OpenGL ES or Vulkan shaders.

That means:

- A native Android app can use them directly only by embedding a Godot runtime or launching a Godot-based module.
- A pure native Android renderer without Godot cannot consume these files as-is.
- If another team wants to use the same visual effects without Godot, the shaders must be rewritten for their rendering stack.

## What To Copy Into Another App

For another Android app that embeds Godot, the minimum reusable pieces are:

1. `generated_shaders/`
2. `project.godot`
3. A Godot scene and script that load and apply the shaders
4. A small Android-to-Godot bridge plugin so the host app can send shader selections into the scene

In this repository, the relevant reference pieces are:

- `generated_shaders/`
- `scripts/android_home.gd`
- `android-app/app/src/main/java/com/smartthings/shaderhome/ShaderHostPlugin.kt`
- `android-app/app/src/main/java/com/smartthings/shaderhome/MainActivity.kt`

## Integration Models

### Option 1: Godot-First App

Use this when the whole app can be a Godot app with a thin Android shell.

- Keep `project.godot`
- Keep your Godot scene as the main scene
- Export an Android build from Godot or package it through the existing Android host

### Option 2: Native Android App Embedding Godot

Use this when the main app is native Android and the 3D home view is one screen or fragment.

This repository already uses that approach:

- `MainActivity.kt` hosts `GodotFragment`
- `ShaderHostPlugin.kt` exposes a signal bridge into Godot
- `android_home.gd` listens for shader-selection updates and applies materials

## How Shader Selection Works

The flow in this project is:

1. Native Android UI collects selected shader ids.
2. Android serializes the ids as JSON.
3. `ShaderHostPlugin` emits `shader_selection_changed`.
4. `android_home.gd` receives that payload.
5. The scene maps shader ids to `ShaderMaterial` or fallback `StandardMaterial3D`.

Reference implementation:

- Android side emits payload from `MainActivity.kt`
- Bridge signal exists in `ShaderHostPlugin.kt`
- Godot side handles selection in `_on_shader_selection_changed()` and `_apply_shader_selection()`

## How To Reuse The Shader Pack In Another App

### Step 1: Package The Godot Project Assets

Include these folders in the Godot project that ships inside your Android app:

- `generated_shaders/`
- `scripts/`
- `scenes/`
- any textures, GLTF/GLB models, and supporting assets referenced by those scripts

### Step 2: Use The Mobile Renderer

For Android, keep Godot on the mobile renderer unless you have a reason to change it.

Recommended settings from this project:

- `renderer/rendering_method="mobile"`
- portrait orientation if your app is portrait
- moderate MSAA only if needed

### Step 3: Create A Small Shader Controller Scene

At minimum, your Godot scene should:

- preload or load the shader files from `generated_shaders/`
- keep arrays of floor meshes, furniture meshes, wall meshes, and overlays
- build `ShaderMaterial` instances with the parameters your UX needs
- expose one method that accepts a list of shader ids and reapplies materials

This project uses:

- `floor_pattern` on floor planes
- `furniture_two_tone_lit` on furniture meshes
- `simple_lit_overlay` on a localized floor overlay
- wall shaders on front and side wall groups separately

### Step 4: Add A Native Bridge

If your host Android app needs to change shaders at runtime, create a simple Godot plugin like this project does.

The pattern is:

- subclass `GodotPlugin`
- define a signal such as `shader_selection_changed`
- emit that signal from Android whenever the native UI changes
- connect to it from GDScript in `_ready()`

### Step 5: Keep Shader IDs Stable

Use the logical ids from `generated_shaders/README.md` and keep them stable across native and Godot layers.

Examples:

- `floor_pattern`
- `furniture_two_tone_lit`
- `simple_lit_overlay`
- `wall_render_outer`
- `wall_render_outer_side`

## Recommended App Structure

For a reusable production-friendly setup:

1. Native Android screen owns the toolbar, dropdowns, filters, and navigation.
2. Godot renders only the 3D home view.
3. Native Android passes a small state payload into Godot:
   - selected shader ids
   - room theme colors
   - device state
   - active floor or camera zoom state
4. Godot applies materials and updates the scene.

This keeps product UI native while leaving visual rendering inside Godot.

## Applying Shaders In Godot

The clean pattern is:

1. Group similar meshes together.
2. Build one material per visual layer.
3. Reuse the same material instance across multiple meshes when they should match.
4. Avoid per-frame material recreation.
5. Reapply only when selection or theme data changes.

In this project:

- floors are stored in `_floors`
- furniture in `_furniture`
- front walls in `_walls_front`
- side/internal walls in `_walls_side`
- overlays in `_simple_overlay`, `_heatmap_overlay`, and `_heatmap_cover_overlay`

## Android Performance Guidance

For Samsung-class Android phones and SmartThings-style scenes:

- prefer the mobile renderer
- keep glow localized instead of full-screen
- avoid too many transparent overlapping planes
- keep wall transparency simple and controlled
- reuse textures and materials
- prefer `.glb` over loose `.gltf` bundles for runtime safety
- avoid huge textures for furniture assets unless they are visually necessary

## GLTF And GLB Asset Rules

### Best Practice

For Android delivery, use `.glb` whenever possible.

Why:

- one file
- fewer packaging mistakes
- fewer case-sensitivity bugs
- no missing `.bin` or texture sidecars

### If Using `.gltf`

A `.gltf` must ship together with every referenced external file:

- `.bin` geometry buffers
- all texture image files
- exact matching filenames
- exact matching case

If any one of those files is missing, Godot will fail to import or instantiate the asset.

## What Your Current `chair.gltf` Needs

Your current `gltf_files/chair.gltf` references external files that are not present next to it.

Required files:

- `ChairDamaskPurplegold.bin`
- `chair_wood_normal.jpg`
- `chair_occlusion.jpg`
- `chair_wood_albedo.jpg`
- `chair_wood_roughness0.jpg`
- `chair_metal_roughness255.jpg`
- `chair_damask_normal.jpg`
- `chair_damask_basecolor.jpg`
- `chair_damask_roughmetal.jpg`
- `chair_label.jpg`

Any one of these missing will stop the asset from loading correctly.

## Best Handoff Format For Future Furniture

If another team wants to add furniture safely, ask for one of these:

1. A self-contained `.glb`
2. A complete `.gltf` folder with:
   - `.gltf`
   - `.bin`
   - all textures
3. A tested Godot-imported scene already verified on Android

The safest handoff is always `.glb`.

## Minimal Native Android Host Checklist

For another Android app embedding this pack:

1. Add Godot Android dependencies.
2. Host a `GodotFragment`.
3. Package the Godot project assets into the app.
4. Add a `GodotPlugin` bridge for shader selection.
5. Send a JSON array of shader ids from native UI to Godot.
6. Keep the Godot scene responsible for material application.
7. Use `.glb` or complete `.gltf` bundles for furniture.
8. Test on a real Android device, not just desktop.

## Recommended Starting Point In This Repository

If someone wants to copy a working pattern, start from:

- `android-app/app/src/main/java/com/smartthings/shaderhome/MainActivity.kt`
- `android-app/app/src/main/java/com/smartthings/shaderhome/ShaderHostPlugin.kt`
- `scripts/android_home.gd`
- `generated_shaders/README.md`

## Troubleshooting

### Shader toggles do nothing

- confirm the shader id matches the logical name
- confirm the Godot script is listening to the native signal
- confirm the mesh group is receiving `material_override`

### Furniture does not show

- prefer `.glb`
- if `.gltf`, verify all sidecar files exist
- verify filename case exactly matches the JSON
- verify the asset is inside the packaged Godot assets

### Scene looks different on Android than desktop

- confirm mobile renderer is enabled
- reduce transparent overlap
- reduce broad emission or heatmap overlays
- test on the actual target Samsung device

### App launches but returns to launcher

- inspect `adb logcat`
- verify `project.godot` and the main scene are packaged
- verify imported assets are present under the merged Android assets

