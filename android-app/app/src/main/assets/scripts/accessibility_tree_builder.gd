class_name AccessibilityTreeBuilder
extends RefCounted

# Builds the accessibility tree pushed to the Android overlay so TalkBack can
# expose Godot's 3D scene as a hierarchy:
#
#     app                                     ("Smart Home")
#       └── floor:<floor.name>                ("First floor")
#             ├── room:<room.id>              ("Living Room, 4 devices")
#             │     ├── device:<device.id>    ("Ceiling light, on, …")
#             │     └── …
#             └── …
#
# Output schema is consumed by `AccessibilityTree.fromJson` on the Kotlin
# side. The list `dfs_order` is what determines TalkBack swipe-right order:
# walking it forward = standard "next" gesture; walking it backward = "previous".
# Because each node also carries a `parent_id`, TalkBack auto-announces
# container entry ("entering Living Room") as focus crosses boundaries.

const APP_NODE_ID := "app"
const APP_LABEL := "Smart Home"

# The overlay rect for the app/floor/room containers is large by design so
# touch-exploration ("drag finger to find") lands on a container even when the
# user's finger is between devices. Devices use their actual screen rect.
const _CONTAINER_PADDING_PX := 96


# Public entry point. All arguments come straight from `android_home.gd`
# state and are not mutated.
#
# `room_entries` — `_room_entries` array (id, label, polygon, centroid…)
# `device_pins`  — `_device_pins` dict keyed by device id
# `device_order` — `_device_pin_order` array; preserves placement order
# `floor_name`   — e.g. "1F"
# `camera`       — current Camera3D (for unproject_position)
# `viewport`     — the viewport whose size defines screen bounds
#
# Always emits the full hierarchy:
#
#     app
#     └── floor
#         ├── room1
#         │   ├── device1.1
#         │   └── device1.2
#         ├── room2
#         │   └── device2.1
#         └── …
#
# TalkBack walks `dfs_order` forward on swipe-right (app → floor → room1 →
# devs → room2 → devs → …) and backward on swipe-left. Past the last
# focusable in the overlay, focus jumps to the next sibling Android view
# (Compose top/side/bottom bars) automatically.
#
# Every node is activatable so TalkBack appends "Double tap to activate" to
# every spoken label. The activation behaviour scales with depth:
#
#   • device  → toggle on / off (existing `_toggle_device_pin`)
#   • room    → zoom the camera into that room
#   • floor   → reset to overview (zoom to full view, default rotation)
#   • app     → same as floor — recentre the scene
static func build(
	room_entries: Array,
	device_pins: Dictionary,
	device_order: Array,
	floor_name: String,
	camera: Camera3D,
	viewport: Viewport,
) -> Dictionary:
	var nodes: Array = []
	var dfs_order: Array = []
	var viewport_size := Vector2(1.0, 1.0)
	if viewport != null:
		viewport_size = viewport.get_visible_rect().size

	var full_rect := _rect_full(viewport_size)

	# 1. App root.
	nodes.append(_node(APP_NODE_ID, "", APP_LABEL, "app", full_rect, true))
	dfs_order.append(APP_NODE_ID)

	# 2. Floor.
	var floor_id := "floor:%s" % floor_name
	var floor_label := _humanise_floor_name(floor_name)
	nodes.append(_node(floor_id, APP_NODE_ID, floor_label, "floor", full_rect, true))
	dfs_order.append(floor_id)

	var devices_by_room := _group_devices_by_room_label(device_pins, device_order)

	# 3. Rooms + their devices, in DFS order.
	for room_entry in room_entries:
		if not (room_entry is Dictionary):
			continue
		var room_dict := room_entry as Dictionary
		var room_id_raw := String(room_dict.get("id", ""))
		if room_id_raw.is_empty():
			continue

		var room_label := String(room_dict.get("label", "Room"))
		var room_id := "room:%s" % room_id_raw
		var room_devices: Array = devices_by_room.get(room_label, [])
		var room_rect := _project_room_rect(room_dict, camera, viewport_size)
		var room_speech := _format_room_label(room_label, room_devices.size())

		nodes.append(_node(room_id, floor_id, room_speech, "room", room_rect, true))
		dfs_order.append(room_id)

		for device_id_raw in room_devices:
			var device := device_pins.get(device_id_raw, {}) as Dictionary
			if device.is_empty():
				continue
			var device_id := "device:%s" % String(device.get("id", device_id_raw))
			var device_rect := _project_device_rect(device, camera, viewport_size)
			var device_speech := _format_device_label(device)
			nodes.append(_node(device_id, room_id, device_speech, "device", device_rect, true))
			dfs_order.append(device_id)

	return {
		"root_id": APP_NODE_ID,
		"nodes": nodes,
		"dfs_order": dfs_order,
	}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

static func _node(
	id: String,
	parent_id: String,
	label: String,
	role: String,
	bounds: PackedInt32Array,
	activatable: bool,
) -> Dictionary:
	return {
		"id": id,
		"parent_id": parent_id,
		"label": label,
		"role": role,
		"bounds": [bounds[0], bounds[1], bounds[2], bounds[3]],
		"activatable": activatable,
	}


# Returns [left, top, right, bottom] in integer pixels, clamped to viewport.
static func _rect_full(viewport_size: Vector2) -> PackedInt32Array:
	var w := int(maxf(viewport_size.x, 1.0))
	var h := int(maxf(viewport_size.y, 1.0))
	return PackedInt32Array([0, 0, w, h])


static func _rect_around(centre: Vector2, half_size: float, viewport_size: Vector2) -> PackedInt32Array:
	var left := int(maxf(centre.x - half_size, 0.0))
	var top := int(maxf(centre.y - half_size, 0.0))
	var right := int(minf(centre.x + half_size, viewport_size.x))
	var bottom := int(minf(centre.y + half_size, viewport_size.y))
	if right <= left:
		right = left + 1
	if bottom <= top:
		bottom = top + 1
	return PackedInt32Array([left, top, right, bottom])


static func _project_device_rect(device: Dictionary, camera: Camera3D, viewport_size: Vector2) -> PackedInt32Array:
	var pin: Variant = device.get("pin", null)
	if pin == null or not (pin is Node3D) or not is_instance_valid(pin) or camera == null or not is_instance_valid(camera):
		# Fallback: tiny offscreen-ish rect at top-left so TalkBack still
		# sees the node but it doesn't fight room rects for hit-testing.
		return PackedInt32Array([0, 0, 1, 1])
	var pin3d := pin as Node3D
	var world_pos: Vector3 = pin3d.global_transform.origin
	if camera.is_position_behind(world_pos):
		return PackedInt32Array([0, 0, 1, 1])
	var screen_pos: Vector2 = camera.unproject_position(world_pos)
	# Pins are visually ~28-40 px depending on zoom; 36 px half-size gives
	# TalkBack a comfortable touch target without hiding adjacent pins.
	return _rect_around(screen_pos, 36.0, viewport_size)


static func _project_room_rect(room_entry: Dictionary, camera: Camera3D, viewport_size: Vector2) -> PackedInt32Array:
	if camera == null or not is_instance_valid(camera):
		return _rect_full(viewport_size)
	var centroid_2d := room_entry.get("centroid", Vector2.ZERO) as Vector2
	# Floor sits on Y = FLOOR_SURFACE_Y in android_home.gd; we want the room's
	# centroid on that plane in world space. The pivot transform is applied in
	# `_home_pivot`, but since the camera is also a child of the same root,
	# unprojecting from the world position works as long as we use the room's
	# polygon points which are stored in pivot-local coordinates after
	# `_scaled_point` re-centred them. Practically, the rect only needs to be
	# *roughly* over the room — TalkBack uses it for explore-by-touch hit
	# testing, not for rendering.
	var world_centroid := Vector3(centroid_2d.x, 0.02, centroid_2d.y)
	if camera.is_position_behind(world_centroid):
		return _rect_full(viewport_size)
	var screen_centroid: Vector2 = camera.unproject_position(world_centroid)
	# Rooms are big — give TalkBack a ~25 % viewport-width target so
	# touch-explore reliably lands on the room in any zoom level.
	var half := minf(viewport_size.x, viewport_size.y) * 0.18
	half = maxf(half, float(_CONTAINER_PADDING_PX))
	return _rect_around(screen_centroid, half, viewport_size)


static func _group_devices_by_room_label(device_pins: Dictionary, device_order: Array) -> Dictionary:
	var grouped := {}
	for device_id in device_order:
		var device := device_pins.get(device_id, {}) as Dictionary
		if device.is_empty():
			continue
		var room_label := String(device.get("room_label", ""))
		if not grouped.has(room_label):
			grouped[room_label] = []
		(grouped[room_label] as Array).append(String(device.get("id", device_id)))
	return grouped


static func _humanise_floor_name(name: String) -> String:
	# "1F" → "First floor", "2F" → "Second floor", else verbatim.
	match name:
		"1F":
			return "First floor"
		"2F":
			return "Second floor"
		"3F":
			return "Third floor"
		"B1":
			return "Basement"
		_:
			if name.is_empty():
				return "Floor"
			return "%s floor" % name


static func _format_room_label(label: String, device_count: int) -> String:
	if device_count <= 0:
		return label
	if device_count == 1:
		return "%s, 1 device" % label
	return "%s, %d devices" % [label, device_count]


static func _format_device_label(device: Dictionary) -> String:
	# TalkBack auto-appends "Double tap to activate" because the node is
	# clickable, so we don't repeat that hint manually. The label only
	# describes identity + current state.
	var name := String(device.get("name", "Device"))
	var kind := String(device.get("kind", ""))
	var is_on := bool(device.get("is_on", false))
	var pieces: Array[String] = [name]

	match kind:
		"air_conditioner":
			var temp_c := int(device.get("temperature_c", 0))
			if temp_c > 0:
				pieces.append("%d degrees" % temp_c)
			pieces.append("on" if is_on else "off")
		"air_purifier":
			var aq := String(device.get("air_quality_state", "")).strip_edges()
			if not aq.is_empty():
				pieces.append("air quality %s" % aq.replace("_", " "))
			pieces.append("running" if is_on else "off")
		"camera":
			pieces.append("live" if is_on else "off")
		"light", _:
			pieces.append("on" if is_on else "off")

	return ", ".join(pieces)
