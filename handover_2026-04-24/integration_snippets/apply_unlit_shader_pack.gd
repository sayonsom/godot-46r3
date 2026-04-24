# Reference implementation — paste into your scene controller that owns
# the floor / wall / furniture mesh lists.
#
# Production-sensible defaults as of 2026-04-24. Adjust per brand guidelines.
# Keep the caching contract (`furniture_lit_materials` meta on each root) so
# the `off` branch can restore lit materials without rebuilding the scene.

const SHADER_WALL_MATERIAL_UNLIT       := preload("res://shaders/wall_material_unlit.gdshader")
const SHADER_FLOOR_MATERIAL_UNLIT      := preload("res://shaders/floor_material_unlit.gdshader")
const SHADER_FURNITURE_DUAL_TONE_UNLIT := preload("res://shaders/furniture_dual_tone_unlit.gdshader")


# Call with `enabled = true` to apply the unlit pack, `false` to restore.
# Assumes the following state on your controller:
#   _floor_nodes         : Array[MeshInstance3D]
#   _wall_tint_entries   : Array of { mesh, is_exterior, room_ids }
#   _furniture_roots     : Array[Node3D]
# and helpers:
#   _room_default_material(color), _floor_finish_material(id),
#   _make_wall_material(is_exterior, tint), _wall_tint_for_room_ids(...),
#   _render_room_finish(entry, id), _default_finish_for_room(entry).
func _apply_unlit_shader_pack(enabled: bool) -> void:
    if not enabled:
        for room_entry in _room_entries:
            var finish_id := String(room_entry.get("finish_id", _default_finish_for_room(room_entry)))
            _render_room_finish(room_entry, finish_id)
        for wall_entry in _wall_tint_entries:
            var wall_mesh := wall_entry.get("mesh", null) as MeshInstance3D
            if not is_instance_valid(wall_mesh):
                continue
            var is_exterior := bool(wall_entry.get("is_exterior", false))
            var tint := _wall_tint_for_room_ids(wall_entry.get("room_ids", []) as Array, is_exterior)
            wall_mesh.material_override = _make_wall_material(is_exterior, tint)
        for root in _furniture_roots:
            if not is_instance_valid(root):
                continue
            var cached := root.get_meta("furniture_lit_materials", {}) as Dictionary
            for mesh_path_key in cached.keys():
                var mesh_node := root.get_node_or_null(String(mesh_path_key))
                if mesh_node is MeshInstance3D:
                    (mesh_node as MeshInstance3D).material_override = cached[mesh_path_key]
        return

    # -------- FLOORS --------
    for floor_node in _floor_nodes:
        if not is_instance_valid(floor_node):
            continue
        var finish := floor_node.material_override as BaseMaterial3D
        var base_color := Color(0.90, 0.88, 0.84, 1.0)
        if finish != null and finish is StandardMaterial3D:
            base_color = (finish as StandardMaterial3D).albedo_color
            base_color.a = 1.0
        var mat := ShaderMaterial.new()
        mat.shader = SHADER_FLOOR_MATERIAL_UNLIT
        mat.set_shader_parameter("base_color", base_color)
        mat.set_shader_parameter("accent_color", Color(base_color.r * 0.92, base_color.g * 0.92, base_color.b * 0.92, 1.0))
        mat.set_shader_parameter("pattern_mode", 1)          # 0=none, 1=checker, 2=stripes
        mat.set_shader_parameter("pattern_strength", 0.18)
        mat.set_shader_parameter("uv_tiling", Vector2(6.0, 6.0))
        mat.set_shader_parameter("edge_vignette", 0.12)
        mat.set_shader_parameter("grain_strength", 0.02)
        mat.set_shader_parameter("grain_scale", 64.0)
        mat.set_shader_parameter("alpha", 1.0)
        floor_node.material_override = mat

    # -------- WALLS --------
    for wall_entry in _wall_tint_entries:
        var wall_mesh := wall_entry.get("mesh", null) as MeshInstance3D
        if not is_instance_valid(wall_mesh):
            continue
        var is_exterior := bool(wall_entry.get("is_exterior", false))
        var tint := _wall_tint_for_room_ids(wall_entry.get("room_ids", []) as Array, is_exterior)
        var base_color := EXTERIOR_WALL_COLOR if is_exterior else Color(tint.r, tint.g, tint.b, 1.0)
        var accent := base_color.darkened(0.12)
        var wall_mat := ShaderMaterial.new()
        wall_mat.shader = SHADER_WALL_MATERIAL_UNLIT
        wall_mat.set_shader_parameter("base_color", base_color)
        wall_mat.set_shader_parameter("accent_color", accent)
        wall_mat.set_shader_parameter("accent_mix", 0.30)
        wall_mat.set_shader_parameter("tone_bias", 0.40)
        wall_mat.set_shader_parameter("vertical_gradient", 0.22)
        wall_mat.set_shader_parameter("grain_strength", 0.035)
        wall_mat.set_shader_parameter("grain_scale", 28.0)
        wall_mat.set_shader_parameter("ambient_darken", 0.14)
        wall_mat.set_shader_parameter("alpha", 1.0)
        wall_mesh.material_override = wall_mat

    # -------- FURNITURE --------
    for root in _furniture_roots:
        if not is_instance_valid(root):
            continue
        if not root.has_meta("furniture_lit_materials"):
            root.set_meta("furniture_lit_materials", {})
        var cache := root.get_meta("furniture_lit_materials", {}) as Dictionary
        var room_color := root.get_meta("furniture_room_color", Color(0.84, 0.86, 0.92)) as Color
        var top_color := room_color.lightened(0.22); top_color.a = 1.0
        var side_color := room_color.darkened(0.18); side_color.a = 1.0
        var accent_color := room_color.darkened(0.40); accent_color.a = 1.0
        var body_overlay: Node = root.get_meta("furniture_body_overlay", null) as Node
        for child in _collect_mesh_instances(root):
            if child == body_overlay:
                continue
            var key := root.get_path_to(child)
            if not cache.has(key):
                cache[key] = child.material_override
            var fmat := ShaderMaterial.new()
            fmat.shader = SHADER_FURNITURE_DUAL_TONE_UNLIT
            fmat.set_shader_parameter("top_color", top_color)
            fmat.set_shader_parameter("side_color", side_color)
            fmat.set_shader_parameter("accent_color", accent_color)
            fmat.set_shader_parameter("side_softness", 0.45)
            fmat.set_shader_parameter("accent_strength", 0.22)
            fmat.set_shader_parameter("rim_strength", 0.14)
            fmat.set_shader_parameter("shadow_wrap", 0.22)
            fmat.set_shader_parameter("color_brightness", 1.0)
            fmat.set_shader_parameter("alpha", 1.0)
            fmat.set_shader_parameter("alpha_clip", 0.05)
            child.material_override = fmat
        root.set_meta("furniture_lit_materials", cache)


func _collect_mesh_instances(root: Node) -> Array:
    var out: Array = []
    if root is MeshInstance3D:
        out.append(root)
    for child in root.get_children():
        out.append_array(_collect_mesh_instances(child))
    return out
