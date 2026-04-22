extends Node3D

const MANIFEST_PATH := "res://generated_shaders/shader_manifest.json"

var _manifest: Array = []
var _current_index := 0
var _selector: OptionButton
var _info_label: Label
var _preview_label: Label
var _canvas_preview: ColorRect
var _spatial_box: MeshInstance3D
var _spatial_plane: MeshInstance3D
var _floor_mesh: MeshInstance3D
var _wall_mesh: MeshInstance3D
var _furniture_mesh: MeshInstance3D
var _textures := {}


func _ready() -> void:
    _textures = _build_textures()
    _build_world()
    _build_ui()
    _manifest = _load_manifest()
    _populate_selector()
    _apply_static_home_materials()
    if not _manifest.is_empty():
        _show_shader(0)


func _process(delta: float) -> void:
    if _spatial_box:
        _spatial_box.rotate_y(delta * 0.45)
    if _spatial_plane:
        _spatial_plane.rotate_y(delta * 0.1)


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_right"):
        _show_shader((_current_index + 1) % _manifest.size())
    elif event.is_action_pressed("ui_left"):
        _show_shader((_current_index - 1 + _manifest.size()) % _manifest.size())


func _load_manifest() -> Array:
    var json_text := FileAccess.get_file_as_string(MANIFEST_PATH)
    var parsed = JSON.parse_string(json_text)
    return parsed if parsed is Array else []


func _build_world() -> void:
    var env := WorldEnvironment.new()
    env.environment = Environment.new()
    env.environment.background_mode = Environment.BG_COLOR
    env.environment.background_color = Color(0.92, 0.95, 0.98)
    env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.environment.ambient_light_color = Color(0.85, 0.88, 0.92)
    env.environment.ambient_light_energy = 0.85
    add_child(env)

    var camera := Camera3D.new()
    camera.position = Vector3(0.0, 4.5, 10.5)
    camera.rotation_degrees = Vector3(-18.0, 0.0, 0.0)
    add_child(camera)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-52.0, 40.0, 0.0)
    sun.light_energy = 1.6
    add_child(sun)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0.0, 3.0, 0.0)
    fill.light_energy = 0.6
    fill.omni_range = 20.0
    add_child(fill)

    var floor_parent := Node3D.new()
    floor_parent.position = Vector3(0.0, 0.0, 0.0)
    add_child(floor_parent)

    _floor_mesh = MeshInstance3D.new()
    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(8.0, 8.0)
    _floor_mesh.mesh = floor_mesh
    floor_parent.add_child(_floor_mesh)

    _wall_mesh = MeshInstance3D.new()
    var wall_box := BoxMesh.new()
    wall_box.size = Vector3(8.0, 3.2, 0.12)
    _wall_mesh.mesh = wall_box
    _wall_mesh.position = Vector3(0.0, 1.6, -4.0)
    add_child(_wall_mesh)

    var side_wall := MeshInstance3D.new()
    side_wall.mesh = wall_box
    side_wall.position = Vector3(-4.0, 1.6, 0.0)
    side_wall.rotation_degrees = Vector3(0.0, 90.0, 0.0)
    side_wall.material_override = _build_named_material("wall_render_outer_side")
    add_child(side_wall)

    _furniture_mesh = MeshInstance3D.new()
    var table_mesh := BoxMesh.new()
    table_mesh.size = Vector3(1.8, 0.8, 1.2)
    _furniture_mesh.mesh = table_mesh
    _furniture_mesh.position = Vector3(-1.2, 0.45, -0.8)
    add_child(_furniture_mesh)

    _spatial_box = MeshInstance3D.new()
    var preview_box_mesh := BoxMesh.new()
    preview_box_mesh.size = Vector3(1.4, 1.4, 1.4)
    _spatial_box.mesh = preview_box_mesh
    _spatial_box.position = Vector3(2.5, 0.8, 1.2)
    add_child(_spatial_box)

    _spatial_plane = MeshInstance3D.new()
    var preview_plane_mesh := PlaneMesh.new()
    preview_plane_mesh.size = Vector2(2.2, 2.2)
    _spatial_plane.mesh = preview_plane_mesh
    _spatial_plane.position = Vector3(2.5, 1.4, 1.2)
    _spatial_plane.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
    _spatial_plane.visible = false
    add_child(_spatial_plane)

    var pedestal := MeshInstance3D.new()
    var pedestal_mesh := CylinderMesh.new()
    pedestal_mesh.top_radius = 0.85
    pedestal_mesh.bottom_radius = 0.95
    pedestal_mesh.height = 0.25
    pedestal.mesh = pedestal_mesh
    pedestal.position = Vector3(2.5, 0.12, 1.2)
    add_child(pedestal)


func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
    panel.position = Vector2(18.0, 18.0)
    panel.custom_minimum_size = Vector2(420.0, 290.0)
    layer.add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_top", 14)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_bottom", 14)
    panel.add_child(margin)

    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    margin.add_child(vbox)

    var title := Label.new()
    title.text = "Shader Preview"
    title.add_theme_font_size_override("font_size", 22)
    vbox.add_child(title)

    _info_label = Label.new()
    _info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(_info_label)

    _selector = OptionButton.new()
    _selector.item_selected.connect(_on_selector_changed)
    vbox.add_child(_selector)

    var button_row := HBoxContainer.new()
    button_row.add_theme_constant_override("separation", 8)
    vbox.add_child(button_row)

    var prev := Button.new()
    prev.text = "Previous"
    prev.pressed.connect(func() -> void:
        _show_shader((_current_index - 1 + _manifest.size()) % _manifest.size())
    )
    button_row.add_child(prev)

    var next := Button.new()
    next.text = "Next"
    next.pressed.connect(func() -> void:
        _show_shader((_current_index + 1) % _manifest.size())
    )
    button_row.add_child(next)

    _preview_label = Label.new()
    _preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(_preview_label)

    _canvas_preview = ColorRect.new()
    _canvas_preview.custom_minimum_size = Vector2(380.0, 120.0)
    _canvas_preview.color = Color.WHITE
    vbox.add_child(_canvas_preview)

    var hint := Label.new()
    hint.text = "Left/Right arrows also switch shaders. Spatial shaders render on the 3D preview stand; canvas shaders render in the panel."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(hint)


func _populate_selector() -> void:
    for item in _manifest:
        _selector.add_item(item.get("name", "Unnamed"))


func _apply_static_home_materials() -> void:
    _floor_mesh.material_override = _build_named_material("floor_pattern")
    _wall_mesh.material_override = _build_named_material("wall_render_outer")
    _furniture_mesh.material_override = _build_named_material("furniture_two_tone_lit")


func _build_named_material(shader_name: String) -> ShaderMaterial:
    for item in _manifest:
        if item.get("name", "") == shader_name:
            return _build_material(item)
    return ShaderMaterial.new()


func _show_shader(index: int) -> void:
    if _manifest.is_empty():
        return
    _current_index = index
    _selector.select(index)
    var entry: Dictionary = _manifest[index]
    var material := _build_material(entry)
    var shader_type := String(entry.get("shader_type", "spatial"))
    var usage := String(entry.get("usage_context", ""))
    _info_label.text = "%s\nType: %s" % [entry.get("name", "Unnamed"), shader_type]
    _preview_label.text = usage

    if shader_type == "canvas_item":
        _canvas_preview.visible = true
        _canvas_preview.material = material
        _spatial_box.visible = false
        _spatial_plane.visible = false
    else:
        _canvas_preview.visible = false
        var use_plane := _should_use_plane(String(entry.get("name", "")))
        _spatial_box.visible = not use_plane
        _spatial_plane.visible = use_plane
        if use_plane:
            _spatial_plane.material_override = material
        else:
            _spatial_box.material_override = material


func _should_use_plane(shader_name: String) -> bool:
    var lowered := shader_name.to_lower()
    return (
        "floor" in lowered
        or "heatmap" in lowered
        or "wall" in lowered
        or "house_texture" in lowered
        or "shadow_catcher" in lowered
        or "triplanar" in lowered
    )


func _on_selector_changed(index: int) -> void:
    _show_shader(index)


func _build_material(entry: Dictionary) -> ShaderMaterial:
    var shader := load(String(entry.get("path", ""))) as Shader
    var material := ShaderMaterial.new()
    material.shader = shader
    for uniform_name in entry.get("uniforms", []):
        _apply_uniform(material, String(entry.get("name", "")), String(uniform_name))
    return material


func _apply_uniform(material: ShaderMaterial, shader_name: String, uniform_name: String) -> void:
    match uniform_name:
        "albedo_texture":
            material.set_shader_parameter(uniform_name, _textures.checker)
        "source_texture":
            material.set_shader_parameter(uniform_name, _textures.wood)
        "_MainTex":
            if shader_name.begins_with("TMP_SDF"):
                material.set_shader_parameter(uniform_name, _textures.sdf)
            else:
                material.set_shader_parameter(uniform_name, _textures.checker)
        "_BaseMap", "_Texture2D", "_BGTex":
            material.set_shader_parameter(uniform_name, _textures.checker)
        "_GradientTexture":
            material.set_shader_parameter(uniform_name, _textures.gradient)
        "_BumpMap", "_DetailNormalMap":
            material.set_shader_parameter(uniform_name, _textures.normal_map)
        "_EmissionMap":
            material.set_shader_parameter(uniform_name, _textures.glow)
        "_ParallaxMap":
            material.set_shader_parameter(uniform_name, _textures.height)
        "_OcclusionMap", "_DetailMask", "_MetallicGlossMap", "_SpecGlossMap":
            material.set_shader_parameter(uniform_name, _textures.mask)
        "albedo_color":
            material.set_shader_parameter(uniform_name, Color(0.91, 0.89, 0.84, 1.0))
        "_BaseColor", "base_color":
            material.set_shader_parameter(uniform_name, Color(0.82, 0.80, 0.77, 1.0))
        "_Color", "source_color", "source_tint":
            material.set_shader_parameter(uniform_name, Color(0.93, 0.95, 0.99, 1.0))
        "_Color2":
            material.set_shader_parameter(uniform_name, Color(0.56, 0.61, 0.68, 0.95))
        "_IconColor":
            material.set_shader_parameter(uniform_name, Color(0.98, 0.91, 0.66, 1.0))
        "_TexColor":
            material.set_shader_parameter(uniform_name, Color(0.95, 0.97, 1.0, 1.0))
        "_GhostLightColor":
            material.set_shader_parameter(uniform_name, Color(0.34, 0.63, 1.0, 1.0))
        "_EmissionColor":
            material.set_shader_parameter(uniform_name, Color(0.12, 0.18, 0.25, 1.0))
        "_SpecColor":
            material.set_shader_parameter(uniform_name, Color(0.25, 0.25, 0.28, 1.0))
        "room_color":
            material.set_shader_parameter(uniform_name, Color(0.88, 0.92, 0.98, 1.0))
        "_GridIndicatorColor0":
            material.set_shader_parameter(uniform_name, Color(0.95, 0.35, 0.28, 1.0))
        "_GridIndicatorColor1":
            material.set_shader_parameter(uniform_name, Color(0.28, 0.72, 0.96, 1.0))
        "uv_tilling", "_Tiling":
            material.set_shader_parameter(uniform_name, Vector2(3.0, 3.0))
        "uv_offset":
            material.set_shader_parameter(uniform_name, Vector2(0.15, 0.05))
        "_Offset":
            if shader_name == "device_progress":
                material.set_shader_parameter(uniform_name, 0.08)
            else:
                material.set_shader_parameter(uniform_name, Vector2(0.15, 0.05))
        "_CutRange":
            material.set_shader_parameter(uniform_name, Vector2(0.25, 0.85))
        "_ClipRect":
            material.set_shader_parameter(uniform_name, Vector4(-1000.0, -1000.0, 1000.0, 1000.0))
        "_BackgroundColor":
            material.set_shader_parameter(uniform_name, Color(0.08, 0.11, 0.14, 1.0))
        "_GridColor":
            material.set_shader_parameter(uniform_name, Color(0.32, 0.36, 0.42, 1.0))
        "topColor":
            material.set_shader_parameter(uniform_name, Color(0.94, 0.92, 0.88))
        "side1Color":
            material.set_shader_parameter(uniform_name, Color(0.42, 0.46, 0.52))
        "side2Color":
            material.set_shader_parameter(uniform_name, Color(0.59, 0.63, 0.70))
        "lightColor":
            material.set_shader_parameter(uniform_name, Color(0.62, 0.78, 1.0))
        "_HorizontalFlip", "_VerticalFlip", "_AlphaClip", "_ReceiveShadows", "_SpecularHighlights", "_EnvironmentReflections", "_ClockWise":
            material.set_shader_parameter(uniform_name, true)
        "_GhostLight", "ghost_effect":
            material.set_shader_parameter(uniform_name, true)
        "reflectivity":
            material.set_shader_parameter(uniform_name, 0.3)
        "_TextureOpacity", "_TextureAlpha", "_Alpha", "alpha", "_BaseOpacity", "_GridFinalAlpha":
            material.set_shader_parameter(uniform_name, 1.0)
        "source_brightness", "color_brightness", "alpha_brightness", "_ColorBrightness":
            material.set_shader_parameter(uniform_name, 1.0)
        "lambert_lighting":
            material.set_shader_parameter(uniform_name, 0.85)
        "dual_tone_strength":
            material.set_shader_parameter(uniform_name, 0.38)
        "shadow_darkness", "_Color2Darkness":
            material.set_shader_parameter(uniform_name, 0.2)
        "alpha_clipping_threshold", "_Cutoff":
            material.set_shader_parameter(uniform_name, 0.08)
        "_Smoothness", "_Glossiness":
            material.set_shader_parameter(uniform_name, 0.35)
        "_IconGlossiness":
            material.set_shader_parameter(uniform_name, 0.08)
        "_Metallic", "_IconMetallic":
            material.set_shader_parameter(uniform_name, 0.05)
        "_BumpScale", "_Scale", "_DetailNormalMapScale":
            material.set_shader_parameter(uniform_name, 1.0)
        "_GradientScale":
            material.set_shader_parameter(uniform_name, 8.0)
        "_TextureWidth", "_TextureHeight":
            material.set_shader_parameter(uniform_name, 128.0)
        "_BaseIntensity":
            material.set_shader_parameter(uniform_name, 0.55)
        "_DitheringRadius":
            material.set_shader_parameter(uniform_name, 0.35)
        "_BaseRadius":
            material.set_shader_parameter(uniform_name, 0.1)
        "_BlendColorRatio", "_BlendOverlaySceneOpacity", "_BlendOverlaySceneRatio":
            material.set_shader_parameter(uniform_name, 0.25)
        "_BlendOverlayWhiteOpacity":
            material.set_shader_parameter(uniform_name, 0.1)
        "_BlendOverlayGaussianCoef", "_InterestOpacityGaussianCoef":
            material.set_shader_parameter(uniform_name, 0.18)
        "_BlendOverlayGaussianBase":
            material.set_shader_parameter(uniform_name, 0.3)
        "_BlendOverlayGaussianOpacity", "_BlendOverlayGaussianRatio", "_InterestOpacityRatio":
            material.set_shader_parameter(uniform_name, 0.25)
        "_InterestOpacityRange":
            material.set_shader_parameter(uniform_name, Vector2(0.18, 0.75))
        "_UnderlayOffsetX", "_UnderlayOffsetY":
            material.set_shader_parameter(uniform_name, 0.4)
        "_UnderlaySoftness", "_OutlineSoftness":
            material.set_shader_parameter(uniform_name, 0.12)
        "_OutlineWidth":
            material.set_shader_parameter(uniform_name, 0.12)
        "_Rotation":
            material.set_shader_parameter(uniform_name, -90.0)
        "_TrimStart":
            material.set_shader_parameter(uniform_name, 0.0)
        "_Length":
            material.set_shader_parameter(uniform_name, 0.72)
        _:
            pass


func _build_textures() -> Dictionary:
    return {
        "checker": _make_checker_texture(Color(0.84, 0.86, 0.89), Color(0.64, 0.69, 0.77)),
        "wood": _make_checker_texture(Color(0.62, 0.44, 0.28), Color(0.52, 0.34, 0.18)),
        "gradient": _make_gradient_texture(),
        "normal_map": _make_flat_normal_texture(),
        "glow": _make_checker_texture(Color(0.05, 0.08, 0.12), Color(0.2, 0.28, 0.4)),
        "height": _make_height_texture(),
        "mask": _make_checker_texture(Color(0.8, 0.8, 0.8), Color(0.25, 0.25, 0.25)),
        "sdf": _make_sdf_texture(),
    }


func _make_checker_texture(a: Color, b: Color, size: int = 128, cells: int = 8) -> Texture2D:
    var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
    for y in size:
        for x in size:
            var cell_x := int(floor(float(x) / float(size / cells)))
            var cell_y := int(floor(float(y) / float(size / cells)))
            image.set_pixel(x, y, a if ((cell_x + cell_y) % 2 == 0) else b)
    return ImageTexture.create_from_image(image)


func _make_gradient_texture(size: int = 128) -> Texture2D:
    var image := Image.create(size, 4, false, Image.FORMAT_RGBA8)
    for x in size:
        var t := float(x) / float(size - 1)
        var color := Color.from_hsv(0.65 - t * 0.65, 0.78, 0.95)
        for y in 4:
            image.set_pixel(x, y, color)
    return ImageTexture.create_from_image(image)


func _make_flat_normal_texture(size: int = 64) -> Texture2D:
    var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
    image.fill(Color(0.5, 0.5, 1.0, 1.0))
    return ImageTexture.create_from_image(image)


func _make_height_texture(size: int = 128) -> Texture2D:
    var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
    for y in size:
        for x in size:
            var value := 0.5 + 0.5 * sin(float(x) * 0.12) * cos(float(y) * 0.12)
            image.set_pixel(x, y, Color(value, value, value, 1.0))
    return ImageTexture.create_from_image(image)


func _make_sdf_texture(size: int = 128) -> Texture2D:
    var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
    var center := Vector2(size * 0.5, size * 0.5)
    var radius := size * 0.28
    for y in size:
        for x in size:
            var distance: float = abs(center.distance_to(Vector2(x, y)) - radius)
            var alpha: float = clamp(1.0 - distance / 10.0, 0.0, 1.0)
            image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
    return ImageTexture.create_from_image(image)
