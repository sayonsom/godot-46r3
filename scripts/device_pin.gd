extends Area3D
class_name DevicePin

const DEVICE_PIN_ICON_DATA := preload("res://scripts/device_pin_icon_data.gd")
const AIR_PURIFIER_DISPLAY_SCRIPT := preload("res://scripts/air_purifier.gd")
const AC_PIN_WAVE_SHADER := preload("res://shaders/device_ac_pin_wave.gdshader")
const LIGHT_GLOW_SHADER := preload("res://shaders/device_light_glow.gdshader")
const LIGHT_CLOUD_SHADER := preload("res://shaders/device_light_cloud.gdshader")
const TEMPERATURE_WASH_SHADER := preload("res://shaders/device_temperature_wash.gdshader")
const PIN_ICON_DITHER_SHADER := preload("res://shaders/pin_icon_dither.gdshader")
const DEVICE_KIND_LIGHT := "light"
const DEVICE_KIND_AIR_CONDITIONER := "air_conditioner"
const DEVICE_KIND_AIR_PURIFIER := "air_purifier"
const AIR_QUALITY_GOOD := "good"
const VISUAL_CENTER_Y := 0.56
const BASE_VIEWPORT_SIZE := Vector2i(256, 332)
const SPINNER_VIEWPORT_SIZE := BASE_VIEWPORT_SIZE
const BASE_PIXEL_SIZE := 0.00435
const PIN_HEIGHT_SCALE := 1.0
const PIN_TIP_OFFSET_RATIO := 40.0 / 24.0
const PIN_OUTLINE_CENTER := Vector2(128.0, 118.0)
const PIN_OUTLINE_RADIUS := 104.0
const PIN_OUTLINE_TIP_Y := PIN_OUTLINE_CENTER.y + PIN_OUTLINE_RADIUS * PIN_TIP_OFFSET_RATIO
const PIN_OUTLINE_BAKE_INTERVAL := 3.5
const PIN_OUTLINE_STROKE_WIDTH := 2.8
const PIN_OUTLINE_TRACE_DURATION := 0.35
const PIN_OUTLINE_TRAIL_WIDTH := 3.2
const SPINNER_OUTLINE_RADIUS := 99.0
const SPINNER_OUTLINE_TIP_Y := PIN_OUTLINE_CENTER.y + SPINNER_OUTLINE_RADIUS * PIN_TIP_OFFSET_RATIO
const SPINNER_GUIDE_WIDTH := 2.6
const SPINNER_TRAIL_WIDTH := 3.0
const SPINNER_DOT_RADIUS := 4.8
const PIN_ICON_DIAMETER_RATIO := 28.0 / 48.0
const PIN_HIGHLIGHT_OFFSET_Y_RATIO := -0.36
const PIN_HIGHLIGHT_RADIUS_X_RATIO := 0.58
const PIN_HIGHLIGHT_RADIUS_Y_RATIO := 0.34
const PIN_HIGHLIGHT_ALPHA_ON := 0.08
const PIN_HIGHLIGHT_ALPHA_OFF := 0.04
const PIN_INNER_SHADOW_ALPHA := 0.28
const PIN_INNER_SHADOW_START := 0.55
const PIN_INNER_SHADOW_END := 1.0
const BASE_WORLD_SIZE := Vector2(
	float(BASE_VIEWPORT_SIZE.x) * BASE_PIXEL_SIZE,
	float(BASE_VIEWPORT_SIZE.y) * BASE_PIXEL_SIZE
)
const SPINNER_WORLD_SIZE := Vector2(
	float(SPINNER_VIEWPORT_SIZE.x) * BASE_PIXEL_SIZE,
	float(SPINNER_VIEWPORT_SIZE.y) * BASE_PIXEL_SIZE
)
const CONTACT_SHADOW_ALPHA := 0.34
const BODY_ON_COLOR := Color(0.19, 0.21, 0.25, 1.0)
const BODY_OFF_COLOR := Color(0.16, 0.18, 0.22, 1.0)
const BODY_OFF_TOP_COLOR := Color(0.42, 0.43, 0.46, 1.0)
const BODY_OFF_BOTTOM_COLOR := Color(0.09, 0.095, 0.11, 1.0)
const ICON_OFF_COLOR := Color(0.78, 0.8, 0.82, 0.92)
const SPINNER_TRAIL_FRACTION := 0.18
const CONTACT_SHADOW_OUTER_SIZE := Vector2(2.1, 2.1)
const CONTACT_SHADOW_INNER_SIZE := Vector2(1.15, 1.15)
const CONTACT_SHADOW_OUTER_HEIGHT := 0.008
const CONTACT_SHADOW_INNER_HEIGHT := 0.0084
const LIGHT_GLOW_OUTER_RADIUS := 2.78
const LIGHT_GLOW_INNER_RADIUS := 1.78
const LIGHT_GLOW_SEGMENTS := 48
const LIGHT_GLOW_OUTER_HEIGHT := 0.0052
const LIGHT_GLOW_INNER_HEIGHT := 0.012
const LIGHT_AURA_SIZE := Vector2(2.55, 2.15)
const LIGHT_AURA_HEIGHT := 0.78
const LIGHT_CLOUD_RADIUS := 1.6
const LIGHT_CLOUD_HEIGHT := 1.35
const LIGHT_CLOUD_Y_SCALE := 1.1
const LIGHT_OMNI_HEIGHT := 0.9
const LIGHT_OMNI_RANGE := 3.6
const LIGHT_OMNI_ENERGY := 2.6
const TEMPERATURE_WASH_FLOOR_HEIGHT := 0.0052
const TEMPERATURE_WASH_RENDER_PRIORITY := -4
const TEMPERATURE_WASH_ROOM_EXPANSION := 0.07
const TEMPERATURE_WALL_OFFSET_C := 1.0
const TEMPERATURE_CALLOUT_VIEWPORT_SIZE := Vector2i(360, 160)
const TEMPERATURE_CALLOUT_PIXEL_SIZE := 0.004
const TEMPERATURE_CALLOUT_ANCHOR_Y := 1.5

static var _icon_texture_cache := {}
static var _contact_shadow_texture: Texture2D
static var _vertical_falloff_texture: Texture2D
static var _soft_radial_texture: Texture2D
static var _icon_grayscale_material: ShaderMaterial

@onready var _name_label: Label3D = $IconAll/Name
@onready var _icon_shadow: MeshInstance3D = $IconAll/IconArea/IconShadow
@onready var _icon_shadow_center: MeshInstance3D = $IconAll/IconArea/IconShadowCenter
@onready var _visual_anchor: Node3D = $IconAll/IconArea/VisualAnchor
@onready var _icon_base: Sprite3D = $IconAll/IconArea/VisualAnchor/IconBase
@onready var _spinner_anchor: Node3D = $IconAll/IconArea/SpinnerAnchor
@onready var _progress_border: MeshInstance3D = $IconAll/IconArea/SpinnerAnchor/ProgressBorder
@onready var _progress: MeshInstance3D = $IconAll/IconArea/SpinnerAnchor/Progress

var _accent_color := Color(1.0, 0.8, 0.29, 1.0)
var _icon_path := ""
var _is_on := true
var _is_pending := false
var _label_text := ""
var _device_kind := DEVICE_KIND_LIGHT
var _light_focus_active := false
var _temperature_focus_active := false
var _air_quality_focus_active := false
var _air_quality_callout_visible := false
var _temperature_c := 24
var _air_quality_state := AIR_QUALITY_GOOD
var _base_viewport: SubViewport
var _base_body: Polygon2D
var _base_rim: Line2D
var _body_highlight: Polygon2D
var _icon_cavity: Polygon2D
var _icon_cavity_rim: Line2D
var _ac_wave_backdrop: ColorRect
var _icon_rect: TextureRect
var _spinner_guide_path := PackedVector2Array()
var _spinner_trail_path := PackedVector2Array()
var _spinner_guide_viewport: SubViewport
var _spinner_trail_viewport: SubViewport
var _spinner_guide_line: Line2D
var _spinner_trail_line: Line2D
var _spinner_dot: Polygon2D
var _pin_outline := PackedVector2Array()
var _light_glow_outer: MeshInstance3D
var _light_glow_inner: MeshInstance3D
var _light_aura_a: MeshInstance3D
var _light_aura_b: MeshInstance3D
var _light_cloud: MeshInstance3D
var _light_omni: OmniLight3D
var _temperature_wash_floor: MeshInstance3D
var _temperature_callout_viewport: SubViewport
var _temperature_callout_label: Label
var _temperature_callout_sprite: Sprite3D
var _temperature_callout_visible := false
var _air_purifier_overlay: Node3D
var _glow_room_polygon := PackedVector2Array()
var _temperature_gradient_center := Vector2.ZERO
var _temperature_gradient_extent := 1.0
var _outline_trace_progress := 0.0
var _outline_trace_tween: Tween


func _ready() -> void:
	input_ray_pickable = false
	collision_layer = 0
	collision_mask = 0
	_name_label.visible = false
	if not _label_text.is_empty():
		_name_label.text = _label_text
	_configure_visual_nodes()
	_pin_outline = _normalize_closed_polygon(
		_device_pin_outline_polygon(PIN_OUTLINE_CENTER, PIN_OUTLINE_RADIUS, PIN_OUTLINE_TIP_Y)
	)
	_build_base_viewport()
	_build_spinner_viewports()
	_rebuild_floor_shadow()
	_build_light_glow()
	_rebuild_light_glow_meshes()
	_build_temperature_wash()
	_rebuild_temperature_wash_meshes()
	_build_air_purifier_overlay()
	_apply_visual_state()
	_set_outline_trace_progress(1.0 if _should_show_active_outline() else 0.0)
	set_bob_offset(0.0)


func _process(_delta: float) -> void:
	_sync_temperature_wash_scale()


func setup_pin(
	icon_path: String,
	accent_color: Color,
	is_on: bool,
	label_text: String = "",
	device_kind: String = DEVICE_KIND_LIGHT,
	glow_room_polygon: PackedVector2Array = PackedVector2Array(),
	temperature_c := 24,
	air_quality_state := AIR_QUALITY_GOOD,
) -> void:
	_icon_path = icon_path
	_accent_color = accent_color
	_is_on = is_on
	_label_text = label_text
	_device_kind = device_kind
	_glow_room_polygon = glow_room_polygon
	_temperature_c = int(temperature_c)
	_air_quality_state = String(air_quality_state)
	if not is_node_ready():
		return
	if not _label_text.is_empty():
		_name_label.text = _label_text
	_rebuild_light_glow_meshes()
	_rebuild_temperature_wash_meshes()
	_sync_air_purifier_overlay()
	_apply_visual_state()


func set_pin_state(is_on: bool, is_pending: bool, accent_color: Color = _accent_color) -> void:
	var previous_outline_visible := _should_show_active_outline()
	_is_on = is_on
	_is_pending = is_pending
	_accent_color = accent_color
	if not is_node_ready():
		return
	_spinner_anchor.visible = _is_pending
	_progress_border.visible = _is_pending
	_progress.visible = _is_pending
	if not _is_pending:
		_set_spinner_progress(0.0)
	_apply_visual_state()
	var target_trace := 1.0 if _should_show_active_outline() else 0.0
	if previous_outline_visible != _should_show_active_outline():
		_animate_outline_trace(target_trace)
	else:
		_set_outline_trace_progress(target_trace)


func set_light_focus_active(is_active: bool) -> void:
	_light_focus_active = is_active
	if not is_node_ready():
		return
	_update_glow_visual()


func set_temperature_focus_active(is_active: bool) -> void:
	_temperature_focus_active = is_active
	if not is_node_ready():
		return
	_update_temperature_wash_visual()


func set_temperature_callout_visible(is_visible: bool) -> void:
	_temperature_callout_visible = is_visible
	if not is_node_ready():
		return
	_update_temperature_wash_visual()


func set_air_quality_focus_active(is_active: bool) -> void:
	_air_quality_focus_active = is_active
	if not is_node_ready():
		return
	_update_air_purifier_visual()


func set_air_quality_callout_visible(is_visible: bool) -> void:
	_air_quality_callout_visible = is_visible
	if not is_node_ready():
		return
	_update_air_purifier_visual()


func set_temperature_c(temperature_c: int) -> void:
	_temperature_c = temperature_c
	if not is_node_ready():
		return
	_update_temperature_wash_visual()


func set_air_quality_state(air_quality_state: String) -> void:
	_air_quality_state = air_quality_state
	if not is_node_ready():
		return
	_sync_air_purifier_overlay()


func set_bob_offset(offset: float) -> void:
	if not is_node_ready():
		return
	_visual_anchor.position.y = VISUAL_CENTER_Y + offset
	_spinner_anchor.position.y = VISUAL_CENTER_Y + offset


func set_pending_progress(progress: float) -> void:
	if not is_node_ready():
		return
	_set_spinner_progress(progress)


func get_screen_anchor_position() -> Vector3:
	if not is_node_ready():
		return global_position + Vector3(0.0, VISUAL_CENTER_Y, 0.0)
	return _visual_anchor.global_position


func play_confirm_pulse() -> void:
	if not is_node_ready():
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual_anchor, "scale", Vector3.ONE * 1.08, 0.12)
	tween.tween_property(_visual_anchor, "scale", Vector3.ONE, 0.18)


func _configure_visual_nodes() -> void:
	_icon_base.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icon_base.pixel_size = BASE_PIXEL_SIZE
	_icon_base.no_depth_test = true
	_icon_base.render_priority = 20
	_icon_base.scale = Vector3(1.0, PIN_HEIGHT_SCALE, 1.0)
	var dither_mat := ShaderMaterial.new()
	dither_mat.shader = PIN_ICON_DITHER_SHADER
	dither_mat.set_shader_parameter("opacity", 0.8)
	dither_mat.set_shader_parameter("alpha_cut", 0.01)
	_icon_base.material_override = dither_mat

	_configure_billboard_quad(_progress_border, SPINNER_WORLD_SIZE, 22)
	_configure_billboard_quad(_progress, SPINNER_WORLD_SIZE, 23)
	_progress_border.scale = Vector3(1.0, PIN_HEIGHT_SCALE, 1.0)
	_progress.scale = Vector3(1.0, PIN_HEIGHT_SCALE, 1.0)
	_spinner_anchor.visible = false
	_progress_border.visible = false
	_progress.visible = false


func _configure_billboard_quad(mesh_instance: MeshInstance3D, size: Vector2, render_priority: int) -> void:
	var mesh := QuadMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.render_priority = render_priority
	mesh_instance.material_override = material


func _build_base_viewport() -> void:
	_base_viewport = SubViewport.new()
	_base_viewport.disable_3d = true
	_base_viewport.transparent_bg = true
	_base_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_base_viewport.size = BASE_VIEWPORT_SIZE
	add_child(_base_viewport)

	var root := Node2D.new()
	_base_viewport.add_child(root)

	var outline := _pin_outline
	var bulb_center := PIN_OUTLINE_CENTER
	var bulb_radius := PIN_OUTLINE_RADIUS
	var bulb_bounds := Rect2(
		bulb_center - Vector2.ONE * bulb_radius,
		Vector2.ONE * bulb_radius * 2.0
	)

	_base_body = Polygon2D.new()
	_base_body.polygon = outline
	root.add_child(_base_body)

	_body_highlight = Polygon2D.new()
	_body_highlight.polygon = _ellipse_polygon(
		bulb_center + Vector2(0.0, bulb_radius * PIN_HIGHLIGHT_OFFSET_Y_RATIO),
		bulb_radius * PIN_HIGHLIGHT_RADIUS_X_RATIO,
		bulb_radius * PIN_HIGHLIGHT_RADIUS_Y_RATIO,
		48
	)
	_body_highlight.texture = _get_soft_radial_texture()
	_body_highlight.uv = _uv_for_rect(
		_body_highlight.polygon,
		Rect2(
			bulb_center + Vector2(
				-bulb_radius * PIN_HIGHLIGHT_RADIUS_X_RATIO,
				bulb_radius * (PIN_HIGHLIGHT_OFFSET_Y_RATIO - PIN_HIGHLIGHT_RADIUS_Y_RATIO)
			),
			Vector2(
				bulb_radius * PIN_HIGHLIGHT_RADIUS_X_RATIO * 2.0,
				bulb_radius * PIN_HIGHLIGHT_RADIUS_Y_RATIO * 2.0
			)
		)
	)
	root.add_child(_body_highlight)

	_icon_cavity = Polygon2D.new()
	_icon_cavity.polygon = _device_pin_circle_polygon(bulb_center, bulb_radius * 0.985, 72)
	_icon_cavity.texture = _get_vertical_falloff_texture()
	_icon_cavity.uv = _uv_for_rect(_icon_cavity.polygon, bulb_bounds)
	root.add_child(_icon_cavity)

	_base_rim = Line2D.new()
	_base_rim.width = PIN_OUTLINE_STROKE_WIDTH
	_base_rim.default_color = Color(1.0, 1.0, 1.0, 0.98)
	_base_rim.joint_mode = Line2D.LINE_JOINT_ROUND
	_base_rim.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_base_rim.end_cap_mode = Line2D.LINE_CAP_ROUND
	_base_rim.z_index = 4
	root.add_child(_base_rim)
	_spinner_guide_path = _normalize_closed_polygon(
		_device_pin_outline_polygon(PIN_OUTLINE_CENTER, SPINNER_OUTLINE_RADIUS, SPINNER_OUTLINE_TIP_Y)
	)
	_spinner_trail_path = _spinner_guide_path.duplicate()

	_icon_cavity_rim = Line2D.new()
	_icon_cavity_rim.points = _icon_cavity.polygon
	_icon_cavity_rim.closed = true
	_icon_cavity_rim.width = 0.0
	root.add_child(_icon_cavity_rim)

	_ac_wave_backdrop = ColorRect.new()
	_ac_wave_backdrop.position = Vector2(126.0, 76.0)
	_ac_wave_backdrop.size = Vector2(44.0, 34.0)
	_ac_wave_backdrop.color = Color.WHITE
	_ac_wave_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ac_wave_backdrop.z_index = 3
	_ac_wave_backdrop.visible = false
	var wave_material := ShaderMaterial.new()
	wave_material.shader = AC_PIN_WAVE_SHADER
	_ac_wave_backdrop.material = wave_material
	root.add_child(_ac_wave_backdrop)

	_icon_rect = TextureRect.new()
	var icon_size := bulb_radius * 2.0 * PIN_ICON_DIAMETER_RATIO
	_icon_rect.position = bulb_center - Vector2.ONE * icon_size * 0.5
	_icon_rect.size = Vector2.ONE * icon_size
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_icon_rect.z_index = 3
	root.add_child(_icon_rect)

	_icon_base.texture = _base_viewport.get_texture()
	var dither_mat := _icon_base.material_override as ShaderMaterial
	if dither_mat != null:
		dither_mat.set_shader_parameter("source_tex", _base_viewport.get_texture())


func _build_spinner_viewports() -> void:
	_spinner_guide_viewport = SubViewport.new()
	_spinner_guide_viewport.disable_3d = true
	_spinner_guide_viewport.transparent_bg = true
	_spinner_guide_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_spinner_guide_viewport.size = SPINNER_VIEWPORT_SIZE
	add_child(_spinner_guide_viewport)

	var guide_root := Node2D.new()
	_spinner_guide_viewport.add_child(guide_root)

	_spinner_guide_line = Line2D.new()
	_spinner_guide_line.points = _spinner_guide_path
	_spinner_guide_line.closed = true
	_spinner_guide_line.width = SPINNER_GUIDE_WIDTH
	_spinner_guide_line.default_color = Color(1.0, 1.0, 1.0, 0.18)
	_spinner_guide_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_spinner_guide_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_spinner_guide_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	guide_root.add_child(_spinner_guide_line)

	_spinner_trail_viewport = SubViewport.new()
	_spinner_trail_viewport.disable_3d = true
	_spinner_trail_viewport.transparent_bg = true
	_spinner_trail_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_spinner_trail_viewport.size = SPINNER_VIEWPORT_SIZE
	add_child(_spinner_trail_viewport)

	var trail_root := Node2D.new()
	_spinner_trail_viewport.add_child(trail_root)

	_spinner_trail_line = Line2D.new()
	_spinner_trail_line.width = SPINNER_TRAIL_WIDTH
	_spinner_trail_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_spinner_trail_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_spinner_trail_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_spinner_trail_line.default_color = Color(1.0, 1.0, 1.0, 0.98)
	trail_root.add_child(_spinner_trail_line)

	_spinner_dot = Polygon2D.new()
	_spinner_dot.polygon = _device_pin_circle_polygon(Vector2.ZERO, SPINNER_DOT_RADIUS, 16)
	_spinner_dot.color = Color(1.0, 1.0, 1.0, 0.98)
	_spinner_dot.visible = false
	trail_root.add_child(_spinner_dot)

	var border_material := _progress_border.material_override as StandardMaterial3D
	border_material.albedo_texture = _spinner_guide_viewport.get_texture()
	var trail_material := _progress.material_override as StandardMaterial3D
	trail_material.albedo_texture = _spinner_trail_viewport.get_texture()


func _build_light_glow() -> void:
	_light_glow_outer = _make_glow_plane(
		LIGHT_GLOW_OUTER_RADIUS,
		Vector3(0.0, LIGHT_GLOW_OUTER_HEIGHT, 0.0),
		12
	)
	_light_glow_inner = _make_glow_plane(
		LIGHT_GLOW_INNER_RADIUS,
		Vector3(0.0, LIGHT_GLOW_INNER_HEIGHT, 0.0),
		13
	)
	_light_aura_a = _make_aura_plane(Vector3(0.0, LIGHT_AURA_HEIGHT, 0.0), 14)
	_light_aura_b = _make_aura_plane(Vector3(0.0, LIGHT_AURA_HEIGHT, 0.0), 15)
	_light_aura_b.rotation_degrees.y = 90.0
	_light_cloud = _make_cloud_sphere(Vector3(0.0, LIGHT_CLOUD_HEIGHT, 0.0), 16)
	add_child(_light_glow_outer)
	add_child(_light_glow_inner)
	add_child(_light_aura_a)
	add_child(_light_aura_b)
	add_child(_light_cloud)

	_light_omni = OmniLight3D.new()
	_light_omni.position = Vector3(0.0, LIGHT_OMNI_HEIGHT, 0.0)
	_light_omni.light_color = Color(1.0, 0.92, 0.74, 1.0)
	_light_omni.light_energy = LIGHT_OMNI_ENERGY
	_light_omni.light_indirect_energy = 0.9
	_light_omni.light_specular = 0.22
	_light_omni.omni_range = LIGHT_OMNI_RANGE
	_light_omni.omni_attenuation = 1.6
	_light_omni.shadow_enabled = false
	_light_omni.visible = false
	add_child(_light_omni)


func _rebuild_light_glow_meshes() -> void:
	if is_instance_valid(_light_glow_outer):
		_light_glow_outer.mesh = _make_glow_mesh(_glow_room_polygon, LIGHT_GLOW_OUTER_RADIUS)
	if is_instance_valid(_light_glow_inner):
		_light_glow_inner.mesh = _make_glow_mesh(_glow_room_polygon, LIGHT_GLOW_INNER_RADIUS)


func _build_temperature_wash() -> void:
	_temperature_wash_floor = MeshInstance3D.new()
	_temperature_wash_floor.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_temperature_wash_floor.visible = false
	_temperature_wash_floor.position = Vector3(0.0, TEMPERATURE_WASH_FLOOR_HEIGHT, 0.0)

	var material := ShaderMaterial.new()
	material.shader = TEMPERATURE_WASH_SHADER
	material.render_priority = TEMPERATURE_WASH_RENDER_PRIORITY
	_temperature_wash_floor.material_override = material
	add_child(_temperature_wash_floor)

	_build_temperature_callout()


func _build_temperature_callout() -> void:
	_temperature_callout_viewport = SubViewport.new()
	_temperature_callout_viewport.disable_3d = true
	_temperature_callout_viewport.transparent_bg = true
	_temperature_callout_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_temperature_callout_viewport.size = TEMPERATURE_CALLOUT_VIEWPORT_SIZE
	add_child(_temperature_callout_viewport)

	var canvas := Control.new()
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_temperature_callout_viewport.add_child(canvas)

	var viewport_w := float(TEMPERATURE_CALLOUT_VIEWPORT_SIZE.x)
	var viewport_h := float(TEMPERATURE_CALLOUT_VIEWPORT_SIZE.y)

	var bubble_width := 300.0
	var bubble_height := 120.0
	var bubble_top := 10.0
	var bubble_left := (viewport_w - bubble_width) * 0.5
	var bubble_bottom := bubble_top + bubble_height
	var pointer_tip_y := viewport_h - 4.0
	var pointer_half_base := 16.0

	var bubble := PanelContainer.new()
	bubble.position = Vector2(bubble_left, bubble_top)
	bubble.size = Vector2(bubble_width, bubble_height)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_theme_stylebox_override("panel", _temperature_callout_bubble_style())
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

	_temperature_callout_label = Label.new()
	_temperature_callout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_temperature_callout_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_temperature_callout_label.add_theme_font_size_override("font_size", 42)
	_temperature_callout_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	_temperature_callout_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.3))
	_temperature_callout_label.add_theme_constant_override("shadow_offset_x", 0)
	_temperature_callout_label.add_theme_constant_override("shadow_offset_y", 1)
	margin.add_child(_temperature_callout_label)

	_temperature_callout_sprite = Sprite3D.new()
	_temperature_callout_sprite.texture = _temperature_callout_viewport.get_texture()
	_temperature_callout_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_temperature_callout_sprite.pixel_size = TEMPERATURE_CALLOUT_PIXEL_SIZE
	_temperature_callout_sprite.no_depth_test = true
	_temperature_callout_sprite.render_priority = 12
	var sprite_half_height := viewport_h * 0.5 * TEMPERATURE_CALLOUT_PIXEL_SIZE
	_temperature_callout_sprite.position = Vector3(
		0.0,
		TEMPERATURE_CALLOUT_ANCHOR_Y + sprite_half_height,
		0.0
	)
	_temperature_callout_sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_temperature_callout_sprite.visible = false
	add_child(_temperature_callout_sprite)


func _temperature_callout_bubble_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.07, 0.97)
	style.corner_radius_top_left = 40
	style.corner_radius_top_right = 40
	style.corner_radius_bottom_left = 40
	style.corner_radius_bottom_right = 40
	return style


func _sync_temperature_wash_scale() -> void:
	if not is_instance_valid(_temperature_wash_floor):
		return
	# Pin is scaled (~0.62 × zoom compensation); counter-scale the wash surface
	# so the polygon renders at world-accurate size for wall-to-wall coverage.
	var world_scale := global_transform.basis.get_scale()
	_temperature_wash_floor.scale = Vector3(
		1.0 / maxf(absf(world_scale.x), 0.0001),
		1.0 / maxf(absf(world_scale.y), 0.0001),
		1.0 / maxf(absf(world_scale.z), 0.0001)
	)


func _rebuild_temperature_wash_meshes() -> void:
	if not is_instance_valid(_temperature_wash_floor):
		return
	var wash_polygon := _expanded_polygon(_glow_room_polygon, TEMPERATURE_WASH_ROOM_EXPANSION)
	if wash_polygon.size() < 3:
		wash_polygon = _glow_room_polygon
	_refresh_temperature_gradient_profile()
	if wash_polygon.size() < 3:
		_temperature_wash_floor.mesh = null
		_temperature_wash_floor.visible = false
		return
	_temperature_wash_floor.mesh = _make_room_polygon_floor_mesh(wash_polygon)


func _make_glow_mesh(room_polygon: PackedVector2Array, radius: float) -> Mesh:
	if room_polygon.size() >= 3:
		var room_mesh := _make_room_glow_mesh(room_polygon, radius, 0.0)
		if room_mesh != null:
			return room_mesh
	return _make_glow_disc_mesh(radius, LIGHT_GLOW_SEGMENTS, 0.0)


func _make_room_polygon_floor_mesh(polygon: PackedVector2Array) -> ArrayMesh:
	var triangulation := Geometry2D.triangulate_polygon(polygon)
	if triangulation.is_empty():
		return null

	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	for point in polygon:
		vertices.append(Vector3(point.x, 0.0, point.y))
		uvs.append(Vector2(point.x, point.y))

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


func _make_glow_plane(radius: float, position: Vector3, render_priority: int) -> MeshInstance3D:
	var glow := MeshInstance3D.new()
	var mesh := _make_glow_disc_mesh(radius, LIGHT_GLOW_SEGMENTS, 0.0)
	glow.mesh = mesh
	glow.position = position
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glow.visible = false

	var material := ShaderMaterial.new()
	material.shader = LIGHT_GLOW_SHADER
	material.render_priority = render_priority
	glow.material_override = material
	return glow


func _make_room_glow_mesh(room_polygon: PackedVector2Array, radius: float, height: float) -> ArrayMesh:
	var polygon_indices := Geometry2D.triangulate_polygon(room_polygon)
	if polygon_indices.is_empty():
		return null

	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var diameter := maxf(radius * 2.0, 0.001)

	for point in room_polygon:
		vertices.append(Vector3(point.x, height, point.y))
		uvs.append(Vector2(point.x / diameter + 0.5, point.y / diameter + 0.5))

	for triangle_index in polygon_indices:
		indices.append(triangle_index)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _refresh_temperature_gradient_profile() -> void:
	_temperature_gradient_center = Vector2.ZERO
	_temperature_gradient_extent = 1.0
	if _glow_room_polygon.size() < 3:
		return

	var centroid := _polygon_centroid(_glow_room_polygon)
	var extent := 0.0
	for point in _glow_room_polygon:
		extent = maxf(extent, centroid.distance_to(point))
	_temperature_gradient_center = centroid
	_temperature_gradient_extent = maxf(extent, 0.5)


func _make_glow_disc_mesh(radius: float, segments: int, height: float) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	vertices.append(Vector3(0.0, height, 0.0))
	uvs.append(Vector2(0.5, 0.5))

	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		var unit := Vector2(cos(angle), sin(angle))
		vertices.append(Vector3(unit.x * radius, height, unit.y * radius))
		uvs.append(unit * 0.5 + Vector2(0.5, 0.5))

	for index in range(segments):
		var current := index + 1
		var next := 1 if index == segments - 1 else current + 1
		indices.append_array([0, next, current])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _expanded_polygon(polygon: PackedVector2Array, expansion: float) -> PackedVector2Array:
	if polygon.size() < 3 or expansion <= 0.0:
		return polygon
	var offset_result: Variant = Geometry2D.offset_polygon(polygon, expansion)
	if not offset_result is Array:
		return polygon
	var offset_polygons := offset_result as Array
	if offset_polygons.is_empty():
		return polygon
	var best_polygon := polygon
	var best_area := absf(_polygon_area(polygon))
	for candidate_variant in offset_polygons:
		if not candidate_variant is PackedVector2Array:
			continue
		var candidate := candidate_variant as PackedVector2Array
		var candidate_area := absf(_polygon_area(candidate))
		if candidate_area > best_area:
			best_area = candidate_area
			best_polygon = candidate
	return best_polygon


func _make_aura_plane(position: Vector3, render_priority: int) -> MeshInstance3D:
	var aura := MeshInstance3D.new()
	var mesh := QuadMesh.new()
	mesh.size = LIGHT_AURA_SIZE
	aura.mesh = mesh
	aura.position = position
	aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	aura.visible = false

	var material := ShaderMaterial.new()
	material.shader = LIGHT_GLOW_SHADER
	material.render_priority = render_priority
	aura.material_override = material
	return aura


func _make_cloud_sphere(position: Vector3, render_priority: int) -> MeshInstance3D:
	var cloud := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = LIGHT_CLOUD_RADIUS
	mesh.height = LIGHT_CLOUD_RADIUS * 2.0 * LIGHT_CLOUD_Y_SCALE
	mesh.radial_segments = 32
	mesh.rings = 18
	cloud.mesh = mesh
	cloud.position = position
	cloud.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cloud.extra_cull_margin = LIGHT_CLOUD_RADIUS
	cloud.visible = false

	var material := ShaderMaterial.new()
	material.shader = LIGHT_CLOUD_SHADER
	material.render_priority = render_priority
	cloud.material_override = material
	return cloud


func _build_air_purifier_overlay() -> void:
	if _device_kind != DEVICE_KIND_AIR_PURIFIER:
		return
	var overlay_variant: Variant = AIR_PURIFIER_DISPLAY_SCRIPT.new()
	if not overlay_variant is Node3D:
		if overlay_variant is Node:
			(overlay_variant as Node).queue_free()
		return
	_air_purifier_overlay = overlay_variant as Node3D
	add_child(_air_purifier_overlay)
	_sync_air_purifier_overlay()


func _rebuild_floor_shadow() -> void:
	_configure_contact_shadow_mesh(
		_icon_shadow,
		CONTACT_SHADOW_OUTER_SIZE,
		Vector3(0.0, CONTACT_SHADOW_OUTER_HEIGHT, 0.0),
		Color(0.0, 0.0, 0.0, CONTACT_SHADOW_ALPHA * 0.7),
		-2
	)
	_configure_contact_shadow_mesh(
		_icon_shadow_center,
		CONTACT_SHADOW_INNER_SIZE,
		Vector3(0.0, CONTACT_SHADOW_INNER_HEIGHT, 0.0),
		Color(0.0, 0.0, 0.0, CONTACT_SHADOW_ALPHA),
		-1
	)


func _configure_contact_shadow_mesh(
	shadow: MeshInstance3D,
	size: Vector2,
	center: Vector3,
	color: Color,
	render_priority: int,
) -> void:
	if not is_instance_valid(shadow):
		return
	var mesh := shadow.mesh as PlaneMesh
	if mesh == null:
		mesh = PlaneMesh.new()
		shadow.mesh = mesh
	mesh.size = size
	shadow.position = center
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var material := shadow.material_override as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		shadow.material_override = material
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	material.albedo_texture = _get_contact_shadow_texture()
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.render_priority = render_priority


func _get_contact_shadow_texture() -> Texture2D:
	if _contact_shadow_texture == null:
		_contact_shadow_texture = _create_contact_shadow_texture()
	return _contact_shadow_texture


func _build_body_off_gradient_colors() -> PackedColorArray:
	var colors := PackedColorArray()
	if _pin_outline.is_empty():
		return colors
	var min_y := INF
	var max_y := -INF
	for p in _pin_outline:
		min_y = minf(min_y, p.y)
		max_y = maxf(max_y, p.y)
	var range_y := maxf(max_y - min_y, 0.0001)
	colors.resize(_pin_outline.size())
	for i in range(_pin_outline.size()):
		var t := clampf((_pin_outline[i].y - min_y) / range_y, 0.0, 1.0)
		t = smoothstep(0.0, 1.0, t)
		colors[i] = BODY_OFF_TOP_COLOR.lerp(BODY_OFF_BOTTOM_COLOR, t)
	return colors


func _get_icon_grayscale_material() -> ShaderMaterial:
	if _icon_grayscale_material == null:
		var shader := Shader.new()
		shader.code = """
shader_type canvas_item;
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(gray), tex.a) * COLOR;
}
"""
		_icon_grayscale_material = ShaderMaterial.new()
		_icon_grayscale_material.shader = shader
	return _icon_grayscale_material


func _create_contact_shadow_texture() -> Texture2D:
	var size := 256
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2((size - 1) * 0.5, (size - 1) * 0.5)
	var radius := size * 0.5
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var stretch := Vector2(delta.x / (radius * 0.96), delta.y / (radius * 0.88))
			var distance := stretch.length()
			var alpha := clampf(1.0 - distance, 0.0, 1.0)
			alpha = alpha * alpha * (3.0 - 2.0 * alpha)
			alpha = pow(alpha, 1.15)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _apply_visual_state() -> void:
	if is_instance_valid(_icon_rect) and _icon_rect.texture == null and not _icon_path.is_empty():
		_icon_rect.texture = _load_icon_texture(_icon_path)

	if _is_on:
		_base_body.color = BODY_ON_COLOR
		_base_body.vertex_colors = PackedColorArray()
	else:
		_base_body.color = Color.WHITE
		_base_body.vertex_colors = _build_body_off_gradient_colors()
	_base_rim.default_color = Color(1.0, 1.0, 1.0, 0.98)
	_body_highlight.color = Color(
		1.0,
		1.0,
		1.0,
		PIN_HIGHLIGHT_ALPHA_ON if _is_on else PIN_HIGHLIGHT_ALPHA_OFF
	)
	_icon_cavity.color = Color(0.0, 0.0, 0.0, PIN_INNER_SHADOW_ALPHA)
	_icon_cavity_rim.default_color = Color(1.0, 1.0, 1.0, 0.0)
	if is_instance_valid(_icon_rect):
		if _is_on:
			_icon_rect.material = null
			_icon_rect.modulate = Color.WHITE
		else:
			_icon_rect.material = _get_icon_grayscale_material()
			_icon_rect.modulate = ICON_OFF_COLOR
	_update_ac_pin_wave_visual()
	_update_glow_visual()
	_update_temperature_wash_visual()
	_update_air_purifier_visual()

	_spinner_anchor.visible = _is_pending
	_progress_border.visible = _is_pending
	_progress.visible = _is_pending


func _should_show_active_outline() -> bool:
	return _is_on and not _is_pending


func _animate_outline_trace(target: float) -> void:
	if _outline_trace_tween != null and _outline_trace_tween.is_valid():
		_outline_trace_tween.kill()
	_outline_trace_tween = create_tween()
	_outline_trace_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_outline_trace_tween.tween_method(
		_set_outline_trace_progress,
		_outline_trace_progress,
		clampf(target, 0.0, 1.0),
		PIN_OUTLINE_TRACE_DURATION
	)


func _set_outline_trace_progress(progress: float) -> void:
	_outline_trace_progress = clampf(progress, 0.0, 1.0)
	if not is_instance_valid(_base_rim):
		return
	if _outline_trace_progress <= 0.001:
		_base_rim.points = PackedVector2Array()
		_base_rim.visible = false
		return
	_base_rim.visible = true
	_base_rim.points = _build_closed_path_prefix(_pin_outline, _outline_trace_progress, 240)


func _update_ac_pin_wave_visual() -> void:
	if not is_instance_valid(_ac_wave_backdrop):
		return
	var show_wave := _device_kind == DEVICE_KIND_AIR_CONDITIONER and _is_on and not _is_pending
	_ac_wave_backdrop.visible = show_wave
	if not show_wave:
		return
	var wave_material := _ac_wave_backdrop.material as ShaderMaterial
	if wave_material == null:
		return
	wave_material.set_shader_parameter("wave_color", Color(0.2, 0.67, 0.92, 0.94))
	wave_material.set_shader_parameter("glow_color", Color(0.53, 0.88, 1.0, 0.3))
	wave_material.set_shader_parameter("speed", 1.24)
	wave_material.set_shader_parameter("amplitude", 0.054)
	wave_material.set_shader_parameter("cycles", 1.28)
	wave_material.set_shader_parameter("line_thickness", 0.024)
	wave_material.set_shader_parameter("glow_thickness", 0.068)
	wave_material.set_shader_parameter("softness", 0.014)
	wave_material.set_shader_parameter("horizontal_padding", 0.08)
	wave_material.set_shader_parameter("vertical_center_a", 0.34)
	wave_material.set_shader_parameter("vertical_center_b", 0.68)


func _update_glow_visual() -> void:
	if not is_instance_valid(_light_glow_outer) or not is_instance_valid(_light_glow_inner):
		return
	var show_glow := _device_kind == DEVICE_KIND_LIGHT and _light_focus_active and _is_on and not _is_pending
	_light_glow_outer.visible = show_glow
	_light_glow_inner.visible = show_glow
	if is_instance_valid(_light_aura_a):
		_light_aura_a.visible = show_glow
	if is_instance_valid(_light_aura_b):
		_light_aura_b.visible = show_glow
	if is_instance_valid(_light_cloud):
		_light_cloud.visible = show_glow
	if is_instance_valid(_light_omni):
		_light_omni.visible = show_glow
	if not show_glow:
		return
	if is_instance_valid(_light_cloud):
		var cloud_material := _light_cloud.material_override as ShaderMaterial
		if cloud_material != null:
			cloud_material.set_shader_parameter("intensity", 1.1)
			cloud_material.set_shader_parameter("glow_color", Color(1.0, 0.86, 0.55, 1.0))
			cloud_material.set_shader_parameter("core_color", Color(1.0, 0.97, 0.82, 1.0))
			cloud_material.set_shader_parameter("density", 2.8)
			cloud_material.set_shader_parameter("core_strength", 0.6)
			cloud_material.set_shader_parameter("vertical_bias", 0.7)
			cloud_material.set_shader_parameter("pulse_speed", 1.25)
			cloud_material.set_shader_parameter("pulse_strength", 0.04)
	var outer_material := _light_glow_outer.material_override as ShaderMaterial
	if outer_material != null:
		outer_material.set_shader_parameter("intensity", 0.38)
		outer_material.set_shader_parameter("glow_color", Color(1.0, 0.89, 0.66, 1.0))
		outer_material.set_shader_parameter("core_color", Color(1.0, 0.97, 0.87, 1.0))
		outer_material.set_shader_parameter("ellipse", 1.06)
		outer_material.set_shader_parameter("softness", 3.2)
		outer_material.set_shader_parameter("core_power", 5.4)
		outer_material.set_shader_parameter("halo_extent", 1.34)
		outer_material.set_shader_parameter("alpha_strength", 0.22)
		outer_material.set_shader_parameter("pulse_strength", 0.022)
		outer_material.set_shader_parameter("pulse_speed", 1.2)
	var inner_material := _light_glow_inner.material_override as ShaderMaterial
	if inner_material != null:
		inner_material.set_shader_parameter("intensity", 0.48)
		inner_material.set_shader_parameter("glow_color", Color(1.0, 0.86, 0.48, 1.0))
		inner_material.set_shader_parameter("core_color", Color(1.0, 0.98, 0.82, 1.0))
		inner_material.set_shader_parameter("ellipse", 1.0)
		inner_material.set_shader_parameter("softness", 2.3)
		inner_material.set_shader_parameter("core_power", 4.4)
		inner_material.set_shader_parameter("halo_extent", 1.12)
		inner_material.set_shader_parameter("alpha_strength", 0.26)
		inner_material.set_shader_parameter("pulse_strength", 0.03)
		inner_material.set_shader_parameter("pulse_speed", 1.48)
	for aura in [_light_aura_a, _light_aura_b]:
		var aura_material := aura.material_override as ShaderMaterial if is_instance_valid(aura) else null
		if aura_material == null:
			continue
		aura_material.set_shader_parameter("intensity", 1.08)
		aura_material.set_shader_parameter("glow_color", Color(1.0, 0.92, 0.72, 1.0))
		aura_material.set_shader_parameter("core_color", Color(1.0, 0.97, 0.86, 1.0))
		aura_material.set_shader_parameter("ellipse", 0.82)
		aura_material.set_shader_parameter("softness", 2.6)
		aura_material.set_shader_parameter("core_power", 5.8)
		aura_material.set_shader_parameter("halo_extent", 1.28)
		aura_material.set_shader_parameter("alpha_strength", 0.58)
		aura_material.set_shader_parameter("pulse_strength", 0.018)
		aura_material.set_shader_parameter("pulse_speed", 1.22)


func _update_temperature_wash_visual() -> void:
	if not is_instance_valid(_temperature_wash_floor):
		return
	var is_ac_active := (
		_device_kind == DEVICE_KIND_AIR_CONDITIONER
		and _temperature_focus_active
		and _is_on
		and not _is_pending
	)
	var show_wash := is_ac_active and _temperature_wash_floor.mesh != null
	_temperature_wash_floor.visible = show_wash
	var show_callout := is_ac_active and _temperature_callout_visible
	if is_instance_valid(_temperature_callout_sprite):
		_temperature_callout_sprite.visible = show_callout
	if show_callout and is_instance_valid(_temperature_callout_label):
		_temperature_callout_label.text = "%d°C" % int(_temperature_c)
	set_process(show_wash or show_callout)
	if not show_wash:
		return

	_sync_temperature_wash_scale()
	var material := _temperature_wash_floor.material_override as ShaderMaterial
	if material == null:
		return
	var center_temperature := float(_temperature_c)
	var wall_temperature := center_temperature + TEMPERATURE_WALL_OFFSET_C
	material.set_shader_parameter("center_temperature", center_temperature)
	material.set_shader_parameter("wall_temperature", wall_temperature)
	material.set_shader_parameter("center_position", _temperature_gradient_center)
	material.set_shader_parameter("room_extent", _temperature_gradient_extent)
	material.set_shader_parameter("tint_alpha", 0.88)
	material.set_shader_parameter("gradient_curve", 1.35)
	material.set_shader_parameter("center_highlight_strength", 0.10)
	material.set_shader_parameter("center_highlight_radius", maxf(_temperature_gradient_extent * 0.45, 0.5))
	material.set_shader_parameter("noise_scale", 1.6)
	material.set_shader_parameter("noise_strength", 0.04)
	material.set_shader_parameter("noise_speed", 0.12)
	material.set_shader_parameter("noise_temp_jitter", 0.25)


func _sync_air_purifier_overlay() -> void:
	if not is_instance_valid(_air_purifier_overlay):
		return
	if _air_purifier_overlay.has_method("setup_air_purifier"):
		_air_purifier_overlay.call(
			"setup_air_purifier",
			_label_text,
			_air_quality_state,
			_glow_room_polygon,
			false
		)
	_update_air_purifier_visual()


func _update_air_purifier_visual() -> void:
	if not is_instance_valid(_air_purifier_overlay):
		return
	if _air_purifier_overlay.has_method("set_focus_active"):
		var show_overlay := (
			_device_kind == DEVICE_KIND_AIR_PURIFIER
			and _air_quality_focus_active
			and not _is_pending
		)
		_air_purifier_overlay.call("set_focus_active", show_overlay)
	if _air_purifier_overlay.has_method("set_callout_visible"):
		var show_callout := (
			_device_kind == DEVICE_KIND_AIR_PURIFIER
			and _air_quality_callout_visible
			and not _is_pending
		)
		_air_purifier_overlay.call("set_callout_visible", show_callout)


func _polygon_centroid(polygon: PackedVector2Array) -> Vector2:
	if polygon.is_empty():
		return Vector2.ZERO
	var signed_area := 0.0
	var centroid := Vector2.ZERO
	for index in range(polygon.size()):
		var current := polygon[index]
		var next := polygon[(index + 1) % polygon.size()]
		var cross := current.x * next.y - next.x * current.y
		signed_area += cross
		centroid += (current + next) * cross
	signed_area *= 0.5
	if absf(signed_area) <= 0.0001:
		for point in polygon:
			centroid += point
		return centroid / float(polygon.size())
	return centroid / (6.0 * signed_area)


func _polygon_area(polygon: PackedVector2Array) -> float:
	var area := 0.0
	for index in range(polygon.size()):
		var current := polygon[index]
		var next := polygon[(index + 1) % polygon.size()]
		area += current.x * next.y - next.x * current.y
	return area * 0.5


func _set_spinner_progress(progress: float) -> void:
	if not _is_pending:
		_spinner_trail_line.points = PackedVector2Array()
		_spinner_dot.visible = false
		return
	var normalized_progress := fposmod(_eased_spinner_progress(progress), 1.0)
	_spinner_trail_line.points = _build_closed_path_segment(
		_spinner_trail_path,
		normalized_progress,
		SPINNER_TRAIL_FRACTION,
		240
	)
	_spinner_dot.visible = true
	_spinner_dot.position = _sample_closed_path(_spinner_trail_path, normalized_progress)


func _eased_spinner_progress(progress: float) -> float:
	var loop_index: float = floor(progress)
	var loop_phase := fposmod(progress, 1.0)
	var eased_phase := 0.5 - 0.5 * cos(loop_phase * PI)
	return loop_index + eased_phase


func _load_icon_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _icon_texture_cache.has(path):
		return _icon_texture_cache[path] as Texture2D
	var texture := DEVICE_PIN_ICON_DATA.create_texture(path)
	if texture == null:
		texture = load(path) as Texture2D
	if texture == null and FileAccess.file_exists(path):
		var image := Image.new()
		if image.load(path) == OK:
			texture = ImageTexture.create_from_image(image)
	if texture == null:
		push_warning("Device icon failed to load: %s" % path)
		return null
	_icon_texture_cache[path] = texture
	return texture


func _device_pin_circle_polygon(center: Vector2, radius: float, segments: int) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		polygon.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return polygon


func _ellipse_polygon(center: Vector2, radius_x: float, radius_y: float, segments: int) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		polygon.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return polygon


func _device_pin_outline_polygon(center: Vector2, radius: float, tip_y: float) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	var tip_offset := maxf(tip_y - center.y, radius + 0.001)
	var alpha := asin(clampf(radius / tip_offset, 0.0, 1.0))
	var tangent_x := radius * cos(alpha)
	var tangent_y := radius * sin(alpha)
	var tip := Vector2(center.x, tip_y)
	var right_tangent := Vector2(center.x + tangent_x, center.y + tangent_y)
	var left_tangent := Vector2(center.x - tangent_x, center.y + tangent_y)
	var arc_length := radius * (PI + 2.0 * alpha)
	var arc_segments := maxi(40, int(ceil(arc_length / PIN_OUTLINE_BAKE_INTERVAL)))

	polygon.append(tip)
	polygon.append(right_tangent)
	for index in range(1, arc_segments):
		var weight := float(index) / float(arc_segments)
		var angle := lerpf(-alpha, PI + alpha, weight)
		polygon.append(center + Vector2(cos(angle), -sin(angle)) * radius)
	polygon.append(left_tangent)
	return polygon


func _normalize_closed_polygon(points: PackedVector2Array) -> PackedVector2Array:
	var normalized := points.duplicate()
	if normalized.size() > 1 and normalized[0].distance_to(normalized[normalized.size() - 1]) <= 0.01:
		normalized.resize(normalized.size() - 1)
	return normalized


func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var shifted := PackedVector2Array()
	for point in points:
		shifted.append(point + offset)
	return shifted


func _uv_for_rect(points: PackedVector2Array, rect: Rect2) -> PackedVector2Array:
	var uv := PackedVector2Array()
	var safe_size := Vector2(maxf(rect.size.x, 0.001), maxf(rect.size.y, 0.001))
	for point in points:
		uv.append((point - rect.position) / safe_size)
	return uv


func _sample_closed_path(points: PackedVector2Array, progress: float) -> Vector2:
	if points.size() < 2:
		return Vector2.ZERO
	var total_length := 0.0
	for index in range(points.size()):
		total_length += points[index].distance_to(points[(index + 1) % points.size()])
	var target := fposmod(progress, 1.0) * total_length
	var accumulated := 0.0
	for index in range(points.size()):
		var from := points[index]
		var to := points[(index + 1) % points.size()]
		var segment_length := from.distance_to(to)
		if accumulated + segment_length >= target:
			var weight := (target - accumulated) / maxf(segment_length, 0.001)
			return from.lerp(to, weight)
		accumulated += segment_length
	return points[0]


func _build_closed_path_segment(points: PackedVector2Array, end_progress: float, length_fraction: float, sample_count: int) -> PackedVector2Array:
	var segment := PackedVector2Array()
	for index in range(sample_count):
		var weight := float(index) / float(max(sample_count - 1, 1))
		var sample_progress := end_progress - length_fraction * (1.0 - weight)
		segment.append(_sample_closed_path(points, sample_progress))
	return segment


func _build_closed_path_prefix(points: PackedVector2Array, end_progress: float, sample_count: int) -> PackedVector2Array:
	var segment := PackedVector2Array()
	var clamped_progress := clampf(end_progress, 0.0, 1.0)
	for index in range(sample_count):
		var weight := float(index) / float(max(sample_count - 1, 1))
		segment.append(_sample_closed_path(points, clamped_progress * weight))
	return segment


func _get_vertical_falloff_texture() -> Texture2D:
	if _vertical_falloff_texture == null:
		_vertical_falloff_texture = _create_vertical_falloff_texture()
	return _vertical_falloff_texture


func _create_vertical_falloff_texture() -> Texture2D:
	var width := 8
	var height := 256
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		var t := float(y) / float(height - 1)
		var alpha := smoothstep(PIN_INNER_SHADOW_START, PIN_INNER_SHADOW_END, t)
		for x in range(width):
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _get_soft_radial_texture() -> Texture2D:
	if _soft_radial_texture == null:
		_soft_radial_texture = _create_soft_radial_texture()
	return _soft_radial_texture


func _create_soft_radial_texture() -> Texture2D:
	var size := 256
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2((size - 1) * 0.5, (size - 1) * 0.5)
	var radius := size * 0.5
	for y in range(size):
		for x in range(size):
			var distance := (Vector2(x, y) - center).length() / radius
			var alpha := clampf(1.0 - distance, 0.0, 1.0)
			alpha = alpha * alpha * (3.0 - 2.0 * alpha)
			alpha = pow(alpha, 1.35)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)
