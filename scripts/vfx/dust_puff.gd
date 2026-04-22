extends Node3D

const DEFAULT_PIECE_COUNT := 14
const MAX_RADIUS := 0.30
const CLEANUP_DELAY := 0.48
const MIN_SCALE := 0.78
const MAX_SCALE := 1.34
const SHADER_TEX_SIZE := 64
const SOFTNESS_EPSILON := 0.0001
const DUST_TEXTURE_PATH := "res://assets/vfx/smoke.png"

@export_range(6, 36, 1) var piece_count: int = DEFAULT_PIECE_COUNT
@export_range(0.08, 0.8, 0.01) var radius: float = MAX_RADIUS
@export_range(0.35, 1.8, 0.05) var duration: float = 0.82
@export var color: Color = Color(0.95, 0.95, 0.95, 0.34)
@export_range(0.08, 1.2, 0.01) var rise: float = 0.34
@export_range(0.05, 0.8, 0.01) var drift: float = 0.30
@export_range(0.08, 0.36, 0.01) var piece_size: float = 0.18
@export_range(0.12, 1.5, 0.05) var flight_boost: float = 0.72

static var _shared_dust_texture: Texture2D


func _ready() -> void:
	_prepare_resources()
	_spawn_burst()


func _spawn_burst() -> void:
	for i in piece_count:
		var piece := _make_piece()
		add_child(piece)
		_animate_piece(piece, i == 0)

	var cleanup := create_tween()
	cleanup.tween_interval(duration + CLEANUP_DELAY)
	cleanup.tween_callback(queue_free)


func _prepare_resources() -> void:
	if _shared_dust_texture != null:
		return

	var loaded_texture := load(DUST_TEXTURE_PATH)
	if loaded_texture is Texture2D:
		_shared_dust_texture = loaded_texture as Texture2D
		return

	var image := Image.create(SHADER_TEX_SIZE, SHADER_TEX_SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(SHADER_TEX_SIZE * 0.5, SHADER_TEX_SIZE * 0.5)
	var radius_limit := float(SHADER_TEX_SIZE) * 0.5
	for y in SHADER_TEX_SIZE:
		for x in SHADER_TEX_SIZE:
			var point := Vector2(float(x) + 0.5, float(y) + 0.5)
			var d: float = point.distance_to(center) / maxf(radius_limit, SOFTNESS_EPSILON)
			var core: float = clamp(1.0 - d, 0.0, 1.0)
			var alpha: float = pow(core, 1.8) * (1.0 - 0.35 * d)
			var fade: float = 1.0 - smoothstep(0.42, 1.0, d)
			var value: float = clamp(alpha * fade, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, value))

	_shared_dust_texture = ImageTexture.create_from_image(image)


func _make_piece() -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(
		piece_size * randf_range(0.92, 1.32),
		piece_size * randf_range(0.92, 1.42)
	)
	mesh.mesh = quad

	var dust_tint := Color(
		clampf(color.r + randf_range(-0.02, 0.02), 0.0, 1.0),
		clampf(color.g + randf_range(-0.02, 0.02), 0.0, 1.0),
		clampf(color.b + randf_range(-0.02, 0.02), 0.0, 1.0),
		clampf(color.a * randf_range(0.86, 1.12), 0.0, 1.0)
	)

	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false
	material.albedo_texture = _shared_dust_texture
	material.albedo_color = dust_tint
	mesh.material_override = material

	mesh.modulate = dust_tint
	mesh.scale = Vector3.ONE * randf_range(MIN_SCALE, MAX_SCALE)
	mesh.rotation = Vector3(0.0, 0.0, randf_range(0.0, TAU))
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.set_meta("dust_tint", dust_tint)

	mesh.position = Vector3(
		randf_range(-0.025, 0.025),
		randf_range(0.0, 0.015),
		randf_range(-0.025, 0.025)
	)

	return mesh


func _animate_piece(piece: MeshInstance3D, lead: bool) -> void:
	var launch_angle := randf_range(0.0, TAU)
	var travel_radius := randf_range(radius * 0.36, radius * 1.02) * randf_range(0.96, 1.24) * flight_boost
	var end_target := piece.position + Vector3(
		cos(launch_angle) * travel_radius + randf_range(-drift, drift) * 0.35,
		randf_range(rise * 0.60, rise * 1.02) * randf_range(0.95, 1.18) * flight_boost,
		sin(launch_angle) * travel_radius + randf_range(-drift, drift) * 0.35
	)

	var bloom_duration := duration * randf_range(0.16, 0.24)
	var fade_duration: float = maxf(0.22, duration - bloom_duration)

	var start_alpha: Color = piece.get_meta("dust_tint", Color(1.0, 1.0, 1.0, 1.0)) as Color
	var peak_alpha := Color(start_alpha.r, start_alpha.g, start_alpha.b, start_alpha.a * 0.98)
	var end_alpha := Color(start_alpha.r, start_alpha.g, start_alpha.b, 0.0)
	var material: Material = piece.material_override
	var dust_material := material if material is StandardMaterial3D else null
	if dust_material == null:
		return
	var std_material := dust_material as StandardMaterial3D

	var jitter := randf_range(0.0, 0.03)
	var initial_spin := piece.rotation.z
	var final_spin := initial_spin + randf_range(-0.95, 0.95)
	var bloom_scale := piece.scale * randf_range(1.45, 2.05)
	var end_scale := bloom_scale * randf_range(1.45, 2.05)

	if lead:
		piece.scale = piece.scale * 1.18
		peak_alpha = Color(peak_alpha.r, peak_alpha.g, peak_alpha.b, minf(1.0, peak_alpha.a * 1.08))
		end_scale = end_scale * 1.10

	var movement_tween := create_tween()
	movement_tween.tween_interval(jitter)
	movement_tween.tween_property(piece, "position", end_target, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	var scale_tween := create_tween()
	scale_tween.tween_interval(jitter)
	scale_tween.tween_property(piece, "scale", bloom_scale, bloom_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(piece, "scale", end_scale, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var alpha_tween := create_tween()
	alpha_tween.tween_interval(jitter)
	alpha_tween.tween_property(std_material, "albedo_color", peak_alpha, bloom_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property(std_material, "albedo_color", end_alpha, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	var rotation_tween := create_tween()
	rotation_tween.tween_interval(jitter)
	rotation_tween.tween_property(piece, "rotation:z", final_spin, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
