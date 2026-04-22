extends Node3D
class_name AirPurifierDisplay

const ROOM_TINT_SHADER := preload("res://shaders/air_quality_room_tint.gdshader")

const QUALITY_GOOD := "good"
const QUALITY_BAD := "bad"
const QUALITY_VERY_BAD := "very_bad"

const TINT_SURFACE_Y := 0.0048  # Sits just above the floor to avoid z-fighting.
const TINT_RENDER_PRIORITY := -4  # Draw before pins so they paint on top.

const FIXTURE_BODY_HEIGHT := 0.24
const FIXTURE_TOP_HEIGHT := 0.024
const FIXTURE_BODY_RADIUS_TOP := 0.076
const FIXTURE_BODY_RADIUS_BOTTOM := 0.09
const FIXTURE_TOP_RADIUS := 0.085

# SmartThings-style floating pill above the pin.
const CALLOUT_VIEWPORT_SIZE := Vector2i(520, 220)
const CALLOUT_PIXEL_SIZE := 0.004
const CALLOUT_ANCHOR_Y := 1.5  # Bottom of bubble sits this far above pin origin.

static var _shadow_texture: Texture2D

var _quality_state := QUALITY_GOOD
var _room_label := ""
var _room_polygon := PackedVector2Array()
var _focus_active := false
var _callout_visible := false
var _show_fixture := true

var _tint_surface: MeshInstance3D
var _tint_material: ShaderMaterial
var _tint_reach := 1.0

var _callout_viewport: SubViewport
var _callout_label: Label
var _callout_sprite: Sprite3D


func _ready() -> void:
	if _show_fixture:
		_build_fixture()
	_build_tint_surface()
	_build_callout()
	_rebuild_tint_surface()
	_apply_quality_visuals()
	_update_focus_visuals()


func setup_air_purifier(
	room_label: String,
	quality_state: String,
	room_polygon: PackedVector2Array,
	show_fixture := true,
) -> void:
	_room_label = room_label
	_quality_state = quality_state
	_room_polygon = room_polygon
	_show_fixture = show_fixture
	if not is_node_ready():
		return
	_rebuild_tint_surface()
	_apply_quality_visuals()
	_update_focus_visuals()


func set_focus_active(is_active: bool) -> void:
	_focus_active = is_active
	if not is_node_ready():
		return
	_update_focus_visuals()


func set_callout_visible(is_visible: bool) -> void:
	_callout_visible = is_visible
	if not is_node_ready():
		return
	_update_focus_visuals()


func _build_fixture() -> void:
	add_child(
		_make_shadow_plane(
			Vector2(0.34, 0.24),
			Vector3(0.0, 0.0012, 0.0),
			Color(0.0, 0.0, 0.0, 0.18)
		)
	)

	var body := MeshInstance3D.new()
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = FIXTURE_BODY_RADIUS_TOP
	body_mesh.bottom_radius = FIXTURE_BODY_RADIUS_BOTTOM
	body_mesh.height = FIXTURE_BODY_HEIGHT
	body_mesh.radial_segments = 20
	body.mesh = body_mesh
	body.position.y = FIXTURE_BODY_HEIGHT * 0.5
	body.material_override = _fixture_material(Color(0.72, 0.73, 0.76, 1.0), 0.92)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(body)

	var top_cap := MeshInstance3D.new()
	var top_mesh := CylinderMesh.new()
	top_mesh.top_radius = FIXTURE_TOP_RADIUS
	top_mesh.bottom_radius = FIXTURE_TOP_RADIUS
	top_mesh.height = FIXTURE_TOP_HEIGHT
	top_mesh.radial_segments = 20
	top_cap.mesh = top_mesh
	top_cap.position.y = FIXTURE_BODY_HEIGHT + FIXTURE_TOP_HEIGHT * 0.5
	top_cap.material_override = _fixture_material(Color(0.83, 0.84, 0.87, 1.0), 0.86)
	top_cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(top_cap)

	var intake_color := _fixture_material(Color(0.6, 0.62, 0.66, 1.0), 0.96)
	for index in range(4):
		var slat := MeshInstance3D.new()
		var slat_mesh := BoxMesh.new()
		slat_mesh.size = Vector3(0.114, 0.01, 0.004)
		slat.mesh = slat_mesh
		slat.position = Vector3(
			0.0,
			0.072 + float(index) * 0.036,
			-(FIXTURE_BODY_RADIUS_BOTTOM - 0.003)
		)
		slat.material_override = intake_color
		slat.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(slat)

	var top_vent := MeshInstance3D.new()
	var top_vent_mesh := CylinderMesh.new()
	top_vent_mesh.top_radius = 0.034
	top_vent_mesh.bottom_radius = 0.034
	top_vent_mesh.height = 0.008
	top_vent_mesh.radial_segments = 18
	top_vent.mesh = top_vent_mesh
	top_vent.position.y = FIXTURE_BODY_HEIGHT + FIXTURE_TOP_HEIGHT + 0.004
	top_vent.material_override = _fixture_material(Color(0.56, 0.58, 0.62, 1.0), 0.98)
	top_vent.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(top_vent)


func _build_tint_surface() -> void:
	_tint_surface = MeshInstance3D.new()
	_tint_surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_tint_surface.visible = false
	_tint_surface.position = Vector3(0.0, TINT_SURFACE_Y, 0.0)

	_tint_material = ShaderMaterial.new()
	_tint_material.shader = ROOM_TINT_SHADER
	_tint_material.render_priority = TINT_RENDER_PRIORITY
	_tint_surface.material_override = _tint_material
	add_child(_tint_surface)


func _build_callout() -> void:
	_callout_viewport = SubViewport.new()
	_callout_viewport.disable_3d = true
	_callout_viewport.transparent_bg = true
	_callout_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_callout_viewport.size = CALLOUT_VIEWPORT_SIZE
	add_child(_callout_viewport)

	var canvas := Control.new()
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_callout_viewport.add_child(canvas)

	var viewport_w := float(CALLOUT_VIEWPORT_SIZE.x)
	var viewport_h := float(CALLOUT_VIEWPORT_SIZE.y)

	var bubble_width := 460.0
	var bubble_height := 170.0
	var bubble_top := 10.0
	var bubble_left := (viewport_w - bubble_width) * 0.5
	var bubble_bottom := bubble_top + bubble_height
	var pointer_tip_y := viewport_h - 4.0
	var pointer_half_base := 16.0

	var bubble := PanelContainer.new()
	bubble.position = Vector2(bubble_left, bubble_top)
	bubble.size = Vector2(bubble_width, bubble_height)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_theme_stylebox_override("panel", _callout_bubble_style())
	canvas.add_child(bubble)

	var pointer := Polygon2D.new()
	pointer.polygon = PackedVector2Array(
		[
			Vector2(viewport_w * 0.5 - pointer_half_base, bubble_bottom - 1.0),
			Vector2(viewport_w * 0.5 + pointer_half_base, bubble_bottom - 1.0),
			Vector2(viewport_w * 0.5, pointer_tip_y),
		]
	)
	pointer.color = Color(0.06, 0.06, 0.07, 0.97)
	canvas.add_child(pointer)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	bubble.add_child(margin)

	# Pill text in the top-bar uses Material `titleMedium` = 16sp. The callout sprite
	# is projected through ortho camera so the viewport font needs to be oversized
	# relative to the sp value to land at the same on-screen pixel size as the pills.
	_callout_label = Label.new()
	_callout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_callout_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_callout_label.add_theme_font_size_override("font_size", 84)
	_callout_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	_callout_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.3))
	_callout_label.add_theme_constant_override("shadow_offset_x", 0)
	_callout_label.add_theme_constant_override("shadow_offset_y", 1)
	margin.add_child(_callout_label)

	_callout_sprite = Sprite3D.new()
	_callout_sprite.texture = _callout_viewport.get_texture()
	_callout_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_callout_sprite.pixel_size = CALLOUT_PIXEL_SIZE
	_callout_sprite.no_depth_test = true
	_callout_sprite.render_priority = 12
	# Position sprite so its bottom edge (pointer tip) sits at CALLOUT_ANCHOR_Y above the pin.
	var sprite_half_height := viewport_h * 0.5 * CALLOUT_PIXEL_SIZE
	_callout_sprite.position = Vector3(0.0, CALLOUT_ANCHOR_Y + sprite_half_height, 0.0)
	_callout_sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_callout_sprite.visible = false
	add_child(_callout_sprite)


func _rebuild_tint_surface() -> void:
	if not is_instance_valid(_tint_surface) or not is_instance_valid(_tint_material):
		return
	if _room_polygon.size() < 3:
		_tint_surface.mesh = null
		_tint_surface.visible = false
		return

	var reach := 0.6
	for point in _room_polygon:
		reach = maxf(reach, point.length())
	_tint_reach = reach

	_tint_surface.mesh = _make_room_polygon_mesh(_room_polygon)
	_tint_material.set_shader_parameter("source_position", Vector2.ZERO)


func _apply_quality_visuals() -> void:
	var palette := _quality_palette()
	var quality_label := String(palette.get("label", "Good"))
	if is_instance_valid(_callout_label):
		_callout_label.text = quality_label

	if not is_instance_valid(_tint_material):
		return

	_tint_material.set_shader_parameter("tint_color", palette.get("tint_color", Color(0.42, 0.82, 0.56, 1.0)))
	_tint_material.set_shader_parameter("highlight_color", palette.get("highlight_color", Color(0.62, 0.92, 0.76, 1.0)))
	_tint_material.set_shader_parameter("tint_alpha", float(palette.get("tint_alpha", 0.82)))
	_tint_material.set_shader_parameter("highlight_radius", maxf(_tint_reach * 0.55, 0.5))
	_tint_material.set_shader_parameter("highlight_strength", float(palette.get("highlight_strength", 0.3)))
	_tint_material.set_shader_parameter("noise_scale", float(palette.get("noise_scale", 1.6)))
	_tint_material.set_shader_parameter("noise_strength", float(palette.get("noise_strength", 0.05)))
	_tint_material.set_shader_parameter("noise_speed", float(palette.get("noise_speed", 0.12)))


func _update_focus_visuals() -> void:
	if is_instance_valid(_tint_surface):
		_tint_surface.visible = _focus_active and _tint_surface.mesh != null
	if is_instance_valid(_callout_sprite):
		_callout_sprite.visible = _callout_visible
	set_process(_focus_active)
	if _focus_active:
		_sync_tint_scale()


func _process(_delta: float) -> void:
	_sync_tint_scale()


func _sync_tint_scale() -> void:
	if not is_instance_valid(_tint_surface):
		return
	# Tint surface inherits rotation/position from the device-pin naturally (no frame
	# lag), but the pin is scaled (~0.62 × zoom comp) — counter-scale the surface so
	# the polygon renders at world-accurate size.
	var world_scale := global_transform.basis.get_scale()
	_tint_surface.scale = Vector3(
		1.0 / maxf(absf(world_scale.x), 0.0001),
		1.0 / maxf(absf(world_scale.y), 0.0001),
		1.0 / maxf(absf(world_scale.z), 0.0001)
	)


func _quality_palette() -> Dictionary:
	match _quality_state:
		QUALITY_BAD:
			return {
				"label": "Bad",
				"tint_color": Color(0.98, 0.58, 0.36, 1.0),
				"highlight_color": Color(1.0, 0.72, 0.52, 1.0),
				"tint_alpha": 0.82,
				"highlight_strength": 0.28,
				"noise_scale": 1.4,
				"noise_strength": 0.05,
				"noise_speed": 0.14,
			}
		QUALITY_VERY_BAD:
			return {
				"label": "Very bad",
				"tint_color": Color(0.92, 0.36, 0.28, 1.0),
				"highlight_color": Color(1.0, 0.56, 0.42, 1.0),
				"tint_alpha": 0.84,
				"highlight_strength": 0.32,
				"noise_scale": 1.5,
				"noise_strength": 0.06,
				"noise_speed": 0.16,
			}
		_:
			return {
				"label": "Good",
				"tint_color": Color(0.42, 0.85, 0.52, 1.0),
				"highlight_color": Color(0.68, 0.96, 0.72, 1.0),
				"tint_alpha": 0.78,
				"highlight_strength": 0.3,
				"noise_scale": 1.6,
				"noise_strength": 0.05,
				"noise_speed": 0.1,
			}


func _make_room_polygon_mesh(polygon: PackedVector2Array) -> ArrayMesh:
	var triangulation := Geometry2D.triangulate_polygon(polygon)
	if triangulation.is_empty():
		return null

	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var bounds := _polygon_bounds(polygon)
	var bmin := bounds[0] as Vector2
	var bmax := bounds[1] as Vector2
	var extent := bmax - bmin
	extent.x = maxf(extent.x, 0.001)
	extent.y = maxf(extent.y, 0.001)

	for point in polygon:
		vertices.append(Vector3(point.x, 0.0, point.y))
		uvs.append(Vector2((point.x - bmin.x) / extent.x, (point.y - bmin.y) / extent.y))

	for triangle_index in triangulation:
		indices.append(triangle_index)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _polygon_bounds(polygon: PackedVector2Array) -> Array:
	if polygon.is_empty():
		return [Vector2.ZERO, Vector2.ZERO]
	var bmin := polygon[0]
	var bmax := polygon[0]
	for point in polygon:
		bmin.x = minf(bmin.x, point.x)
		bmin.y = minf(bmin.y, point.y)
		bmax.x = maxf(bmax.x, point.x)
		bmax.y = maxf(bmax.y, point.y)
	return [bmin, bmax]


func _fixture_material(base_color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base_color
	material.roughness = roughness
	material.metallic = 0.02
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _callout_bubble_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.07, 0.97)
	style.corner_radius_top_left = 40
	style.corner_radius_top_right = 40
	style.corner_radius_bottom_left = 40
	style.corner_radius_bottom_right = 40
	return style


func _make_shadow_plane(size: Vector2, center: Vector3, color: Color) -> MeshInstance3D:
	var shadow := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	shadow.mesh = mesh
	shadow.position = center
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = _shadow_plane_texture()
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	shadow.material_override = material
	return shadow


func _shadow_plane_texture() -> Texture2D:
	if _shadow_texture == null:
		_shadow_texture = _create_shadow_texture()
	return _shadow_texture


func _create_shadow_texture() -> Texture2D:
	var size := 192
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2((size - 1) * 0.5, (size - 1) * 0.5)
	var radius := size * 0.5
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var stretch := Vector2(delta.x / (radius * 0.98), delta.y / (radius * 0.82))
			var distance := stretch.length()
			var alpha := clampf(1.0 - distance, 0.0, 1.0)
			alpha = alpha * alpha * (3.0 - 2.0 * alpha)
			alpha = pow(alpha, 1.14)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)
