# Virtual Home Handoff

Last updated: 2026-04-18

## Goal

This project is building a Samsung SmartThings-style "Virtual Home" viewer on Android using Godot for the 3D floor-plan scene and a native Android Compose overlay for the app chrome.

Current package:

- `com.smartthings.shaderhome`

## Main Files

- Godot scene logic: `/Users/sayon/Documents/Codes/Backend/godot-46r3/scripts/android_home.gd`
- Android activity/UI overlay: `/Users/sayon/Documents/Codes/Backend/godot-46r3/android-app/app/src/main/java/com/smartthings/shaderhome/MainActivity.kt`
- Godot plugin bridge: `/Users/sayon/Documents/Codes/Backend/godot-46r3/android-app/app/src/main/java/com/smartthings/shaderhome/ShaderHostPlugin.kt`
- Android layout host: `/Users/sayon/Documents/Codes/Backend/godot-46r3/android-app/app/src/main/res/layout/activity_main.xml`
- Sample floor-plan data: `/Users/sayon/Documents/Codes/Backend/godot-46r3/data/sample_floor_plan.json`
- Furniture assets: `/Users/sayon/Documents/Codes/Backend/godot-46r3/GLB/`

## Current Renderer State

The Godot renderer now supports:

- room polygons from floor-plan JSON
- translucent walls in a SmartThings-like cutaway style
- pastel room fills
- floor label decals rendered via `SubViewport` textures
- per-furniture contact shadows
- room tap-to-zoom
- pinch zoom
- rotation in 90-degree steps
- furniture placement mode with preview

## Placement Pipeline

Placement logic was refactored into explicit steps in `android_home.gd`:

- `_instantiate_furniture_model(model_id)`
- `_sample_floor_height(position_2d)`
- `_ground_model_to_floor(model, model_id)`
- `_build_contact_shadow(local_aabb, room_color, model_id, is_preview)`
- `_create_furniture_root(...)`

Current grounding is intentionally model-specific, not generic.

Key grounding constants:

```gdscript
const FURNITURE_FLOOR_EPSILON := 0.0

const MODEL_FLOOR_OFFSETS := {
	"cabinet": -0.008,
	"small_table": -0.016,
	"step_stool": -0.022,
	"stool": -0.03,
}
```

These were introduced because the GLB pivots/bounds do not all sit cleanly on the floor.

## Furniture Placement UX

Android now has a furniture drawer:

- tap the `+` button in the top bar to open the drawer
- select one of: `cabinet`, `small_table`, `step_stool`, `stool`
- drag/tap on the floor to preview placement
- release to place
- use the rotate button to rotate the preview/item by 90 degrees
- tap `Done` to exit placement mode

Bridge signal added:

- `furniture_selection_changed`

## Current Visual Tuning Notes

- Shadows are in a reasonable place visually.
- Main remaining tuning area is still furniture grounding per asset.
- If an item still looks like it floats, prefer adjusting `MODEL_FLOOR_OFFSETS` for that one model instead of changing the global epsilon again.
- If offsets become too fragile, the better long-term fix is asset-level pivot/origin normalization in the GLBs.

## Floor Labels

Floor labels are now decal-style instead of `Label3D`.

Important current values:

```gdscript
label.add_theme_font_size_override("font_size", 62)
var width := clampf(text.length() * 0.22, 0.88, 2.7)
plane.size = Vector2(width, 0.38)
```

## Android Overlay Structure

The app overlay was split into separate Compose views so the center of the screen remains touchable by Godot:

- top controls
- side controls
- bottom controls

This change was important for making pinch/drag work reliably.

## Build / Install Commands

Godot parse check:

```bash
/opt/homebrew/bin/godot --headless --path /Users/sayon/Documents/Codes/Backend/godot-46r3 --quit
```

Android build:

```bash
cd /Users/sayon/Documents/Codes/Backend/godot-46r3/android-app
./gradlew assembleDebug
```

ADB install:

```bash
adb install -r -d /Users/sayon/Documents/Codes/Backend/godot-46r3/android-app/app/build/outputs/apk/debug/app-debug.apk
```

ADB relaunch:

```bash
adb shell am start -n com.smartthings.shaderhome/.MainActivity
```

## Recommended Next Steps

1. Fine-tune `MODEL_FLOOR_OFFSETS` per asset after visual checks on device.
2. Add placement collision rules so new furniture cannot overlap walls or other furniture.
3. Add a visible preview outline/highlight when placing furniture.
4. Add persistence for user-placed furniture instead of keeping placement in-memory only.
5. Consider normalizing GLB pivots so runtime grounding becomes simpler and more stable.
