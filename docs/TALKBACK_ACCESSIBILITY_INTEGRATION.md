# TalkBack Accessibility Integration Guide for Godot-on-Android Apps

This guide shows you how to take the Smart Home app's TalkBack hierarchy
(app → floor → rooms → device pins) and reuse the same architecture in any
Android app that hosts a Godot 3D scene.

The pattern is **rendering-engine-agnostic** on the Android side and
**Android-agnostic** on the Godot side — you only need to keep the JSON
contract between them stable.

---

## 1. What you get

- TalkBack swipe-right walks your 3D scene as a logical hierarchy.
- TalkBack swipe-left walks it back.
- Single-tap or touch-explore lands focus on whatever 3D object is under the
  finger. Double-tap activates (toggle a device, zoom to a room, recenter,
  whatever you choose).
- Compose / Views *outside* your Godot fragment still work normally; you can
  control where they fall in the swipe order.
- Pan / pinch / twist gestures on the Godot fragment are **untouched** —
  the accessibility layer never consumes touch events.

---

## 2. Architecture at a glance

```
┌──────────────────────────────────────────────────────────────────┐
│  MainActivity  (FrameLayout root)                                │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │  GodotFragment                                               │ │
│ │   └ GLSurfaceView    ← 3D scene rendered here                │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │  AccessibilityOverlayView   (transparent, match_parent)      │ │
│ │   ├ HomeExploreByTouchHelper (virtual-view delegate)         │ │
│ │   │   ├ virtual node 1: "Smart Home"                         │ │
│ │   │   ├ virtual node 2: "First floor"                        │ │
│ │   │   ├ virtual node 3: "Bedroom, 2 devices"                 │ │
│ │   │   └ … (one per Godot object)                             │ │
│ │   └ Touch events: passthrough (returns false)                │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │  Other Compose / Views   (top bar, side controls, bottom nav) │ │
│ └──────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
                             ▲
                             │  publishAccessibilityTree(json)
                             │  notifyAccessibilityFocus(id)
                             │  notifyAccessibilityActivate(id)
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│  ShaderHostPlugin   (GodotPlugin singleton — your bridge)        │
└──────────────────────────────────────────────────────────────────┘
                             ▲ ▼
┌──────────────────────────────────────────────────────────────────┐
│  Godot scene  (e.g. android_home.gd)                             │
│  • _publish_accessibility_tree() builds a JSON snapshot,          │
│    serialises it via JSON.stringify, calls plugin.call(…).       │
│  • _on_accessibility_activate(id) handles double-taps.           │
│  • _on_accessibility_focus_changed(id) mirrors focus visually.   │
└──────────────────────────────────────────────────────────────────┘
```

The two sides only communicate via:

1. A JSON tree snapshot Godot pushes when state or camera changes.
2. Two signals (`accessibility_focus_changed`, `accessibility_activate`)
   the plugin fires when TalkBack focuses or double-taps a virtual node.

That's it. Any 3D engine that can serialise a screen-space tree to JSON
can plug into the Android side without modification.

---

## 3. Files to copy

### Android side (Kotlin)

Drop these into your existing GodotPlugin module — keep the package path
or rename freely, just keep them together:

| File | Role |
|---|---|
| `accessibility/AccessibilityTree.kt` | Plain data classes + JSON parser. Backend-agnostic. |
| `accessibility/HomeExploreByTouchHelper.kt` | Bridges the tree to TalkBack via androidx `ExploreByTouchHelper`. |
| `accessibility/AccessibilityOverlayView.kt` | Transparent View with touch-passthrough. Hosts the helper. |

You also need to:

- Add `androidx.customview:customview:1.1.0` to `app/build.gradle.kts`
  (transitively pulled in by appcompat, but pin it explicitly).
- Extend your existing `GodotPlugin` subclass with two signals + two
  `@UsedByGodot` methods (template in §6).
- Place an `<AccessibilityOverlayView>` in your activity layout (template
  in §5).

### Godot side (GDScript)

| File | Role |
|---|---|
| `scripts/accessibility_tree_builder.gd` | Pure helper; converts your scene state → tree dict. |
| Hooks in your scene controller (e.g. `android_home.gd`) | ~150 lines; see §7. |

Reference implementation: see `android-app/app/src/main/java/com/smartthings/shaderhome/accessibility/`
and `scripts/accessibility_tree_builder.gd` + `scripts/android_home.gd` in
this repo.

---

## 4. The JSON contract (the only thing you can't change)

Godot publishes this dictionary; the Kotlin side parses it into typed
nodes. Stable schema = forward-compatible across rendering changes.

```jsonc
{
  "root_id": "app",
  "nodes": [
    {
      "id":          "app",                  // unique stable string
      "parent_id":   "",                     // "" means root
      "label":       "Smart Home",           // spoken by TalkBack
      "role":        "app",                  // app | floor | room | device
      "bounds":      [0, 0, 1080, 2340],     // [left, top, right, bottom] in overlay-pixel space
      "activatable": true                    // true → TalkBack appends "Double tap to activate"
    },
    {
      "id":          "floor:1F",
      "parent_id":   "app",
      "label":       "First floor",
      "role":        "floor",
      "bounds":      [0, 0, 1080, 2340],
      "activatable": true
    },
    {
      "id":          "room:<uuid>",
      "parent_id":   "floor:1F",
      "label":       "Living, 4 devices",
      "role":        "room",
      "bounds":      [471, 1068, 859, 1457],
      "activatable": true
    },
    {
      "id":          "device:<uuid>",
      "parent_id":   "room:<uuid>",
      "label":       "Living Light, on",
      "role":        "device",
      "bounds":      [631, 1248, 703, 1320],
      "activatable": true
    }
    // … more nodes …
  ],
  "dfs_order": [
    "app", "floor:1F",
    "room:<uuid-1>", "device:<uuid-1.1>", "device:<uuid-1.2>",
    "room:<uuid-2>", "device:<uuid-2.1>",
    // …
  ]
}
```

### Field rules

- **`id`** — any unique string. Convention: `kind:underlying-id`
  (`device:abc-123`). The Kotlin side never inspects the prefix; it just
  uses the string as a virtual-view key.
- **`bounds`** — pixel coordinates in the overlay View's coordinate space.
  Use `Camera3D.unproject_position(world_pos)` from Godot, then center a
  small rect around the pin (~36 px half-size for devices). For containers
  whose interactive area is fuzzy (rooms, floors), use the centroid + a
  generous half-size.
- **`activatable`** — `true` makes the node clickable. TalkBack will
  automatically append "Double tap to activate" to its announcement.
- **`dfs_order`** — **this is the swipe order**. Right-swipe walks it
  forward, left-swipe walks it back. Whatever ordering you compose here
  is the order users will experience.
- **`parent_id`** — currently unused by the Kotlin helper (we deliberately
  flatten under the host View — see §10), but keep emitting it so future
  accessibility backends (e.g. AccessKit Android) can use it.

---

## 5. The activity layout

Add the overlay as a sibling of your Godot fragment **above** it in the
FrameLayout child list (so it sits visually on top, but its
touch-passthrough lets gestures fall through to Godot).

```xml
<!-- res/layout/activity_main.xml -->
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <!-- Godot first (drawn at the bottom of z-stack) -->
    <androidx.fragment.app.FragmentContainerView
        android:id="@+id/godot_fragment_container"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

    <!-- Accessibility overlay above Godot but below your UI chrome.
         Touch events fall through (see AccessibilityOverlayView). -->
    <com.yourcompany.yourapp.accessibility.AccessibilityOverlayView
        android:id="@+id/accessibility_overlay"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:importantForAccessibility="yes"
        android:contentDescription="@string/accessibility_overlay_label" />

    <!-- Your Compose / View chrome on top -->
    <androidx.compose.ui.platform.ComposeView
        android:id="@+id/top_controls_compose_view"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="top" />

    <!-- … more Compose chrome … -->
</FrameLayout>
```

Add the string resource:

```xml
<!-- res/values/strings.xml -->
<string name="accessibility_overlay_label">Smart Home floorplan</string>
```

Use any phrase you like — TalkBack reads this when the user touches an
empty area of your 3D view.

---

## 6. Plugin signal additions

Extend your existing `GodotPlugin` subclass. The pattern mirrors any
existing signals you already have.

```kotlin
class ShaderHostPlugin(godot: Godot, …) : GodotPlugin(godot) {

    interface ActivityBridge {
        // … your existing callbacks …

        /** Always invoked on the UI thread. */
        fun onAccessibilityTreeUpdated(json: String)

        /** Transient announcement — e.g. "Light turned on". */
        fun onAccessibilityAnnounce(text: String)
    }

    companion object {
        // Add to your existing SignalInfo block.
        private val ACCESSIBILITY_FOCUS_CHANGED =
            SignalInfo("accessibility_focus_changed", String::class.java)
        private val ACCESSIBILITY_ACTIVATE =
            SignalInfo("accessibility_activate", String::class.java)
    }

    override fun getPluginSignals() = setOf(
        // … your existing signals …
        ACCESSIBILITY_FOCUS_CHANGED,
        ACCESSIBILITY_ACTIVATE,
    )

    // Java → Godot (called from the overlay when TalkBack focuses or activates)
    fun notifyAccessibilityFocus(nodeId: String) {
        emitSignal(ACCESSIBILITY_FOCUS_CHANGED.name, nodeId)
    }

    fun notifyAccessibilityActivate(nodeId: String) {
        emitSignal(ACCESSIBILITY_ACTIVATE.name, nodeId)
    }

    // Godot → Java (called from GDScript via plugin.call(...))
    @UsedByGodot
    fun publishAccessibilityTree(json: String) {
        getActivity()?.runOnUiThread {
            activityBridge?.onAccessibilityTreeUpdated(json)
        }
    }

    @UsedByGodot
    fun announceForAccessibility(text: String) {
        getActivity()?.runOnUiThread {
            activityBridge?.onAccessibilityAnnounce(text)
        }
    }
}
```

In your `MainActivity`:

```kotlin
class MainActivity : AppCompatActivity(), ShaderHostPlugin.ActivityBridge {

    private var accessibilityOverlay: AccessibilityOverlayView? = null

    override fun onCreate(...) {
        super.onCreate(...)
        setContentView(R.layout.activity_main)
        bindGodotFragment()           // your existing code
        bindAccessibilityOverlay()    // new
    }

    private fun bindAccessibilityOverlay() {
        val overlay = findViewById<AccessibilityOverlayView>(R.id.accessibility_overlay) ?: return
        accessibilityOverlay = overlay
        overlay.setListener(object : AccessibilityOverlayView.Listener {
            override fun onAccessibilityFocusChanged(nodeId: String) {
                shaderHostPlugin?.notifyAccessibilityFocus(nodeId)
            }
            override fun onAccessibilityActivate(nodeId: String) {
                shaderHostPlugin?.notifyAccessibilityActivate(nodeId)
            }
        })
    }

    override fun onAccessibilityTreeUpdated(json: String) {
        val tree = AccessibilityTree.fromJson(json)
        accessibilityOverlay?.updateTree(tree)
    }

    override fun onAccessibilityAnnounce(text: String) {
        accessibilityOverlay?.announce(text)
    }
}
```

---

## 7. The Godot side — minimal hooks

In your main scene controller (mirrors `scripts/android_home.gd`):

### 7a. Constants and state

```gdscript
const APP_PLUGIN_NAME := "YourPluginName"   # whatever your GodotPlugin reports
const SIGNAL_ACCESSIBILITY_FOCUS_CHANGED := "accessibility_focus_changed"
const SIGNAL_ACCESSIBILITY_ACTIVATE := "accessibility_activate"
const JAVA_METHOD_PUBLISH_ACCESSIBILITY_TREE := "publishAccessibilityTree"
const JAVA_METHOD_ANNOUNCE_FOR_ACCESSIBILITY := "announceForAccessibility"

const AccessibilityTreeBuilder := preload("res://scripts/accessibility_tree_builder.gd")

var _a11y_publish_timer: SceneTreeTimer = null
var _a11y_initial_publish_done := false
var _a11y_focused_node_id := ""
# Cached transforms used to detect when the camera or pivot has moved enough
# to warrant republishing the tree.
var _a11y_last_camera_origin := Vector3.INF
var _a11y_last_camera_basis_x := Vector3.INF
var _a11y_last_pivot_rotation_y := INF
var _a11y_last_zoom_scale := -1.0
```

### 7b. Connect to the plugin (once)

```gdscript
func _connect_app_plugin() -> void:
    if not Engine.has_singleton(APP_PLUGIN_NAME):
        return
    var plugin := Engine.get_singleton(APP_PLUGIN_NAME)
    if plugin == null:
        return

    if plugin.has_signal(SIGNAL_ACCESSIBILITY_FOCUS_CHANGED):
        plugin.connect(SIGNAL_ACCESSIBILITY_FOCUS_CHANGED,
            Callable(self, "_on_accessibility_focus_changed"))
    if plugin.has_signal(SIGNAL_ACCESSIBILITY_ACTIVATE):
        plugin.connect(SIGNAL_ACCESSIBILITY_ACTIVATE,
            Callable(self, "_on_accessibility_activate"))

    # First publish runs after the scene is built; this handles late connects.
    _publish_accessibility_tree_debounced()
```

### 7c. The publisher (debounced)

```gdscript
func _publish_accessibility_tree_debounced() -> void:
    if _a11y_publish_timer != null:
        return  # existing timer will fire shortly
    if get_tree() == null:
        return
    _a11y_publish_timer = get_tree().create_timer(0.2)   # 200 ms debounce
    _a11y_publish_timer.timeout.connect(_publish_accessibility_tree, CONNECT_ONE_SHOT)


func _publish_accessibility_tree() -> void:
    _a11y_publish_timer = null
    if not Engine.has_singleton(APP_PLUGIN_NAME):
        return
    var plugin := Engine.get_singleton(APP_PLUGIN_NAME)
    if plugin == null:
        return

    var tree := AccessibilityTreeBuilder.build(
        # …whatever your scene-state arguments are…
        _your_scene_objects,
        _camera,
        get_viewport(),
    )
    var dfs_order: Array = tree.get("dfs_order", []) as Array
    # Defensive: never publish a tree that would empty the host. If the
    # builder somehow produces no nodes (e.g. transient camera state), keep
    # the helper's previous tree alive so TalkBack can still navigate.
    if dfs_order.size() < 2:
        return

    plugin.call(JAVA_METHOD_PUBLISH_ACCESSIBILITY_TREE, JSON.stringify(tree))
    _a11y_initial_publish_done = true

    # Snapshot transforms so the per-frame dirty check only fires on changes.
    if is_instance_valid(_camera):
        _a11y_last_camera_origin = _camera.global_transform.origin
        _a11y_last_camera_basis_x = _camera.global_transform.basis.x
    _a11y_last_pivot_rotation_y = your_pivot.rotation.y
    _a11y_last_zoom_scale = your_zoom_scale
```

### 7d. Camera-move detection (per frame)

```gdscript
func _process(delta: float) -> void:
    # … your existing per-frame logic …
    _check_accessibility_camera_dirty()


func _check_accessibility_camera_dirty() -> void:
    if not _a11y_initial_publish_done:
        return
    if not is_instance_valid(_camera):
        return
    var camera_origin := _camera.global_transform.origin
    var camera_basis_x := _camera.global_transform.basis.x
    if (
        camera_origin.distance_squared_to(_a11y_last_camera_origin) > 0.000004
        or camera_basis_x.distance_squared_to(_a11y_last_camera_basis_x) > 0.000004
        or absf(your_pivot.rotation.y - _a11y_last_pivot_rotation_y) > 0.002
        or absf(your_zoom_scale - _a11y_last_zoom_scale) > 0.002
    ):
        _publish_accessibility_tree_debounced()
```

### 7e. Activation handler

```gdscript
func _on_accessibility_activate(node_id: String) -> void:
    var sep := node_id.find(":")
    var kind := node_id.substr(0, sep) if sep >= 0 else node_id
    var raw_id := node_id.substr(sep + 1) if sep >= 0 else ""

    match kind:
        "device":
            _toggle_device(raw_id)        # your toggle fn
        "room":
            _zoom_to_room(raw_id)
        "floor", "app":
            _zoom_to_overview()
```

### 7f. Optional: focus-change handler

If you want to mirror TalkBack focus visually (e.g. spotlight the focused
pin), connect this — otherwise leave it out.

```gdscript
func _on_accessibility_focus_changed(node_id: String) -> void:
    _a11y_focused_node_id = node_id
    # apply a focus shader / outline / pulse to the matching object
```

### 7g. Republish trigger sites

Call `_publish_accessibility_tree_debounced()` from anywhere a labelled
state changes:

| Event | Why |
|---|---|
| End of scene build (rooms / pins instantiated) | First publish so TalkBack has something to read. |
| End of plugin-connect block | Handles late connects. |
| Confirmed device state change (`is_on`, name, etc.) | Label changes. |
| Viewport resize (`NOTIFICATION_WM_SIZE_CHANGED`) | All bounds invalidated. |
| Per-frame camera dirty-check (above) | Pan / pinch / twist / animation. |

---

## 8. Compose chrome buttons (siblings of the overlay)

For Compose buttons next to your Godot fragment (e.g. a 3D/2D toggle, a
rotate icon):

```kotlin
@Composable
private fun MyButton(label: String, onClick: () -> Unit, contentDescription: String) {
    val colorScheme = MaterialTheme.colorScheme
    Box(
        modifier = Modifier
            .size(54.dp)
            .clip(CircleShape)
            .background(colorScheme.surfaceVariant)
            // Semantics MUST come before clickable. Compose creates the
            // semantic boundary at the first semantics-producing modifier
            // in the chain, and clickable produces its own boundary. By
            // putting semantics(mergeDescendants=true) first, the outer
            // boundary owns both the contentDescription and (via merge)
            // the click action that clickable adds below it.
            .semantics(mergeDescendants = true) {
                this.contentDescription = contentDescription
            }
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = label,
            // Suppress the inner Text's standalone semantic node so the
            // merge above is the only focusable accessibility node.
            modifier = Modifier.clearAndSetSemantics {},
        )
    }
}
```

For state-aware labels (e.g. "Switch to 2D view" vs "Switch to 3D view"),
recompute the contentDescription each composition based on your state.

### Controlling the swipe order with sibling Views

By default TalkBack walks FrameLayout children in their child-index order.
The accessibility overlay comes first because of its position in the XML
above. To change the order without reshuffling the visual z-stack, use
`accessibilityTraversalAfter` *carefully* — it can interact badly with
ExploreByTouchHelper-driven virtual children if applied to a sibling that
shares bounds with the overlay. Prefer reordering FrameLayout children
when possible.

---

## 9. Tree structure & traversal order

### What ends up where

```
app             ← virtual root (full viewport)
└─ floor        ← logical container (full viewport)
   ├─ room A   ← container for objects in this region (centroid + half-size)
   │  ├─ device 1   ← leaf: actual screen-projected pin bounds
   │  └─ device 2
   ├─ room B
   │  └─ device 3
   └─ …
```

**TalkBack swipe-right** = walk `dfs_order` forward.
**TalkBack swipe-left** = walk `dfs_order` backward.

### Two display models you can pick

The `dfs_order` you publish controls the user experience. Pick one:

#### Linear DFS (recommended default)

Emit every node, every time. Right-swipe walks `app → floor → room1 →
its devices → room2 → its devices → …`. This is what the Smart Home app
ships with. Devices are immediately reachable; rooms act as audible
"section headers."

#### Drill-down

Maintain a `selected_room_id` state in GDScript. When empty, emit
`app + floor + all rooms` (no devices). When set, emit `app + floor +
[just the selected room with "double tap to exit" hint] + its devices`.
Activation toggles the state.

This pattern is implemented in commit history of `accessibility_tree_builder.gd`
if you want to look at it. Choose linear DFS unless your scene has many
hundreds of devices and TalkBack swipe latency becomes a real concern.

---

## 10. The two non-obvious invariants

### 10a. Touch passthrough is mandatory

The overlay sits z-above the Godot fragment. If it consumes
`MotionEvent`s, your pan / pinch / twist breaks. The provided
`AccessibilityOverlayView` returns `false` from both `dispatchTouchEvent`
and `onTouchEvent`. Don't change that.

Hover events (touch-explore / TalkBack drag) need a separate path —
forward them to the helper:

```kotlin
override fun dispatchHoverEvent(event: MotionEvent): Boolean {
    if (helper.dispatchHoverEvent(event)) return true
    return super.dispatchHoverEvent(event)
}
```

### 10b. Don't set virtual parents on the AccessibilityNodeInfoCompat

The provided helper deliberately skips `node.setParent(host, parentVirtualId)`.
On modern Android (API 30+), `ExploreByTouchHelper` resolves screen
bounds for a virtual view by **summing** bounds-in-parent up the virtual
chain. We pass screen-pixel coordinates as bounds-in-parent, so for any
deeply nested node the framework computes a wildly offscreen sum and the
OS clamps it to `[0,0,0,0]`. Result: half your virtual views silently
become invisible to TalkBack.

Solution implemented in `HomeExploreByTouchHelper.kt`: every virtual view
is parented directly under the host (the overlay). Bounds-in-parent =
bounds-in-screen. The hierarchy you publish in `parent_id` is preserved
in the JSON for future use (e.g. with a different backend), but the
helper flattens it.

If TalkBack's "entering Living Room" container announcements matter to
you, lift them into the spoken `label` ("Living, 4 devices, double tap
to activate") instead of relying on virtual parenting.

---

## 11. Debounce, debounce, debounce

`ExploreByTouchHelper.invalidateRoot()` fires on every tree update. Each
invalidate forces TalkBack to re-query the helper, and during that
rebuild window TalkBack briefly sees zero virtual children. If you
republish on every frame during a 1-second camera animation, you can
hide the entire overlay for several hundred milliseconds total — making
TalkBack swipes silently fail.

The reference implementation uses a 200 ms debounce. Don't go below
~120 ms unless you've measured the impact on a slow device.

Three rules of thumb:

- ✅ **Republish on real state changes** (device toggled, room renamed,
  viewport resized).
- ✅ **Republish on camera movement** if your scene's screen-space bounds
  depend on the camera (almost always true). Use the dirty-check pattern
  in §7d so you don't publish on truly-still frames.
- ❌ **Never publish empty trees**. The provided GDScript guard refuses
  to publish if `dfs_order.size() < 2`. ExploreByTouchHelper will hide
  the host View when it has zero virtual children — and once hidden, it
  often stays hidden until the activity is re-created.

---

## 12. Activation behaviours (your design choice)

The activate handler in §7e is the "what should double-tap do at each
level" decision. Reasonable defaults that the Smart Home app uses:

| Node kind | Activation | Why |
|---|---|---|
| `device` | Toggle on/off (no popup) | Simplest, matches "Double tap to activate or deactivate" mental model. |
| `room`   | Zoom camera into the room | Matches the visual tap behaviour. |
| `floor`  | Zoom out to overview | Mirrors a "home" button. |
| `app`    | Same as floor (recentre) | Consistent escape hatch. |

If a node has no meaningful action, set `activatable: false` in the JSON
and TalkBack will not append "Double tap to activate" to its label.

---

## 13. Debugging cheat sheet

### Dump the live accessibility tree from the device

```bash
adb shell uiautomator dump /sdcard/a11y.xml
adb pull /sdcard/a11y.xml
```

Parse it with this one-liner:

```bash
python3 -c '
import re, sys
xml = open("a11y.xml").read()
for m in re.finditer(r"<node[^>]*?\/?>", xml):
    nd = m.group(0)
    cd = re.search(r"content-desc=\"([^\"]*)\"", nd)
    txt = re.search(r"text=\"([^\"]*)\"", nd)
    label = (cd.group(1) if cd and cd.group(1) else (txt.group(1) if txt and txt.group(1) else ""))
    if not label: continue
    click = re.search(r"clickable=\"(true|false)\"", nd)
    bounds = re.search(r"bounds=\"(\[[^\]]+\]\[[^\]]+\])\"", nd)
    print(f"  click={click.group(1) if click else \"?\":5s}  bounds={bounds.group(1) if bounds else \"?\":24s}  {label}")
'
```

If your overlay nodes don't appear, check (in order):

1. Is the GodotPlugin connected? (Look for your "plugin singleton found"
   log on app start.)
2. Did GDScript actually publish? Add a `print()` to
   `_publish_accessibility_tree` and watch logcat. The reference
   implementation logs `[SmartHome] a11y publish: N nodes (root=app)`.
3. Is `dfs_order.size() >= 2`? If not, the defensive guard suppresses
   the publish (which is correct).
4. Is the overlay View `importantForAccessibility="yes"` AND laid out
   with non-zero size?

### Watch the bridge from logcat

```bash
adb logcat --pid=$(adb shell pidof com.yourcompany.yourapp) | grep -iE 'a11y|accessibility'
```

### Verify TalkBack is actually on

```bash
adb shell settings get secure enabled_accessibility_services
adb shell settings get secure accessibility_enabled
```

If `accessibility_enabled` is `1` and the service list contains
`com.google.android.marvin.talkback/...` (or Samsung's variant), TalkBack
is active. Otherwise turn it on in `Settings → Accessibility → TalkBack`
or via:

```bash
adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService
adb shell settings put secure accessibility_enabled 1
```

---

## 14. Integration checklist

Copy-pasteable. Tick as you go.

- [ ] **Files copied**
  - [ ] `accessibility/AccessibilityTree.kt`
  - [ ] `accessibility/HomeExploreByTouchHelper.kt`
  - [ ] `accessibility/AccessibilityOverlayView.kt`
  - [ ] `scripts/accessibility_tree_builder.gd`
- [ ] **Build config**
  - [ ] `androidx.customview:customview:1.1.0` declared in `app/build.gradle.kts`
- [ ] **Layout**
  - [ ] `<AccessibilityOverlayView>` added to `activity_main.xml` above
        the Godot fragment, below your UI chrome
  - [ ] `accessibility_overlay_label` string resource added
- [ ] **Plugin (Kotlin)**
  - [ ] Two new `SignalInfo`s registered in `getPluginSignals()`
  - [ ] `notifyAccessibilityFocus` / `notifyAccessibilityActivate` Kotlin
        methods added (called from the overlay)
  - [ ] `@UsedByGodot` `publishAccessibilityTree(json)` added
  - [ ] `@UsedByGodot` `announceForAccessibility(text)` added
  - [ ] `ActivityBridge` extended with two new callbacks
- [ ] **Activity**
  - [ ] `bindAccessibilityOverlay()` wired in `onCreate` (or wherever you
        bind the Godot fragment)
  - [ ] `onAccessibilityTreeUpdated(json)` parses with
        `AccessibilityTree.fromJson` and calls `overlay.updateTree(...)`
  - [ ] `onAccessibilityAnnounce(text)` calls `overlay.announce(...)`
- [ ] **GDScript**
  - [ ] `accessibility_tree_builder.gd` preloaded in your scene
        controller
  - [ ] `_publish_accessibility_tree_debounced()` called from end of
        scene build, end of plugin connect, on confirmed state change,
        on viewport resize
  - [ ] `_check_accessibility_camera_dirty()` called from `_process`
  - [ ] `_on_accessibility_focus_changed(id)` connected and (optionally)
        mirrored visually
  - [ ] `_on_accessibility_activate(id)` connected and dispatching
        per-kind handlers
- [ ] **Verification**
  - [ ] `uiautomator dump` on a fresh launch shows your virtual nodes
        (count matches what GDScript published)
  - [ ] TalkBack swipe right walks the expected order
  - [ ] TalkBack double-tap activates the right thing per kind
  - [ ] TalkBack OFF: pan / pinch / twist on the Godot fragment unchanged
        (overlay must not steal touches — test by aggressively panning
        across the entire viewport)

---

## 15. Reference implementation files

In this repository, the canonical files to crib from:

| Layer | File |
|---|---|
| Android — overlay | `android-app/app/src/main/java/com/smartthings/shaderhome/accessibility/AccessibilityOverlayView.kt` |
| Android — TalkBack helper | `android-app/app/src/main/java/com/smartthings/shaderhome/accessibility/HomeExploreByTouchHelper.kt` |
| Android — tree data model | `android-app/app/src/main/java/com/smartthings/shaderhome/accessibility/AccessibilityTree.kt` |
| Android — bridge plugin | `android-app/app/src/main/java/com/smartthings/shaderhome/ShaderHostPlugin.kt` |
| Android — activity wiring | `android-app/app/src/main/java/com/smartthings/shaderhome/MainActivity.kt` (search for `bindAccessibilityOverlay`) |
| Android — layout | `android-app/app/src/main/res/layout/activity_main.xml` |
| Godot — tree builder | `scripts/accessibility_tree_builder.gd` |
| Godot — scene wiring | `scripts/android_home.gd` (search for `_publish_accessibility_tree`, `_on_accessibility_activate`) |

---

## 16. FAQ

**Q. Can I support multiple Godot scenes / activities?**
A. Yes. The plugin singleton persists across activity lifetimes. Each
activity binds its own overlay. Godot republishes the tree when its
scene tree rebuilds, so navigation snaps to the new scene automatically.

**Q. What about AccessKit?**
A. Godot 4.4+ ships AccessKit bindings, but only for desktop platforms
today. The Android exporter doesn't bridge AccessKit nodes to TalkBack,
which is why this guide uses the overlay-View pattern. The
`AccessibilityTree` data model is intentionally backend-agnostic — when
Godot's Android AccessKit support lands (or when the
`dev.accesskit:accesskit-android` adapter matures), you can replace
`HomeExploreByTouchHelper` without touching either the GDScript side or
your activity wiring.

**Q. How do I localise spoken labels?**
A. Build the `label` string in GDScript with translated content; Godot
has `tr()` for runtime translation. The Kotlin side just relays whatever
you put in the JSON.

**Q. My device toggle "lights up" visually but TalkBack still says "off".**
A. The state announcement comes from the next tree republish. After a
state-confirmation callback, call `_publish_accessibility_tree_debounced()`
to force a refresh and optionally `_announce_for_accessibility("Light
turned on")` to read the change immediately.

**Q. I see weird focus jumps during the intro animation.**
A. The 200 ms debounce in §11 should cover this. If your animation is
shorter than the debounce, focus can briefly land on a stale-bounds
node. Bump the debounce to 250 – 300 ms or skip republishing while a
specific tween is in flight.
