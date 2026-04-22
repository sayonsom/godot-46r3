extends Control
class_name SkinEditorUI

signal edit_mode_requested(enabled: bool)
signal home_skin_selected(skin_id: String)
signal room_finish_preview_requested(finish_id: String)
signal room_finish_apply_requested()
signal room_finish_cancel_requested()
signal apply_room_finish_to_all_requested()

var _edit_button: Button
var _top_panel: PanelContainer
var _skin_buttons_root: HBoxContainer
var _room_panel: PanelContainer
var _room_name_label: Label
var _room_hint_label: Label
var _finish_buttons_root: HFlowContainer
var _apply_all_button: Button
var _cancel_button: Button
var _apply_button: Button

var _skin_buttons := {}
var _finish_buttons := {}
var _active_skin_id := ""
var _active_finish_id := ""
var _edit_mode := false
var _has_selected_room := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	resized.connect(_refresh_layout)
	_refresh_layout()
	set_edit_mode(false)
	clear_selected_room()


func configure(home_skin_models: Array, finish_models: Array) -> void:
	_rebuild_home_skin_buttons(home_skin_models)
	_rebuild_finish_buttons(finish_models)


func set_edit_mode(enabled: bool) -> void:
	_edit_mode = enabled
	if is_instance_valid(_edit_button):
		_edit_button.text = "Done" if enabled else "Edit skin"
	if is_instance_valid(_top_panel):
		_top_panel.visible = enabled
	if is_instance_valid(_room_panel):
		_room_panel.visible = enabled and _has_selected_room


func set_active_skin(skin_id: String) -> void:
	_active_skin_id = skin_id
	for current_skin_id in _skin_buttons.keys():
		var button := _skin_buttons[current_skin_id] as Button
		if is_instance_valid(button):
			button.button_pressed = current_skin_id == skin_id


func show_selected_room(room_name: String, finish_id: String) -> void:
	_has_selected_room = true
	_active_finish_id = finish_id
	if is_instance_valid(_room_name_label):
		_room_name_label.text = room_name
	if is_instance_valid(_room_hint_label):
		_room_hint_label.text = "Preview a finish, then apply or cancel."
	if is_instance_valid(_room_panel):
		_room_panel.visible = _edit_mode
	_update_finish_button_states()


func set_selected_finish(finish_id: String) -> void:
	_active_finish_id = finish_id
	_update_finish_button_states()


func clear_selected_room() -> void:
	_has_selected_room = false
	_active_finish_id = ""
	if is_instance_valid(_room_name_label):
		_room_name_label.text = "Select a room"
	if is_instance_valid(_room_hint_label):
		_room_hint_label.text = "Tap a room in edit mode to preview floor finishes."
	if is_instance_valid(_room_panel):
		_room_panel.visible = false
	_update_finish_button_states()


func _refresh_layout() -> void:
	var viewport_size := size
	if viewport_size == Vector2.ZERO:
		return

	var top_clearance := viewport_size.y * 0.16
	var bottom_clearance := viewport_size.y * 0.16
	if is_instance_valid(_edit_button):
		_edit_button.position = Vector2(24.0, top_clearance + 12.0)

	if is_instance_valid(_top_panel):
		_top_panel.anchor_left = 0.04
		_top_panel.anchor_right = 0.96
		_top_panel.anchor_top = 0.0
		_top_panel.anchor_bottom = 0.0
		_top_panel.offset_left = 0.0
		_top_panel.offset_right = 0.0
		_top_panel.offset_top = top_clearance + 78.0
		_top_panel.offset_bottom = _top_panel.offset_top + minf(420.0, viewport_size.y * 0.24)

	if is_instance_valid(_room_panel):
		var panel_height := minf(430.0, viewport_size.y * 0.33)
		_room_panel.anchor_left = 0.08
		_room_panel.anchor_right = 0.92
		_room_panel.anchor_top = 1.0
		_room_panel.anchor_bottom = 1.0
		_room_panel.offset_left = 0.0
		_room_panel.offset_right = 0.0
		_room_panel.offset_bottom = -(bottom_clearance + 24.0)
		_room_panel.offset_top = _room_panel.offset_bottom - panel_height


func _build_ui() -> void:
	_edit_button = Button.new()
	_edit_button.text = "Edit skin"
	_edit_button.position = Vector2(24.0, 24.0)
	_edit_button.custom_minimum_size = Vector2(144.0, 48.0)
	_edit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_edit_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.1, 0.1, 0.12, 0.9), 18, Color(0.28, 0.28, 0.32, 1.0)))
	_edit_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.16, 0.16, 0.18, 0.94), 18, Color(0.4, 0.4, 0.46, 1.0)))
	_edit_button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.22, 0.22, 0.24, 0.96), 18, Color(0.46, 0.46, 0.52, 1.0)))
	_edit_button.pressed.connect(_on_edit_button_pressed)
	add_child(_edit_button)

	_top_panel = PanelContainer.new()
	_top_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_top_panel.anchor_left = 0.04
	_top_panel.anchor_right = 0.96
	_top_panel.anchor_top = 0.1
	_top_panel.anchor_bottom = 0.34
	_top_panel.offset_top = 32.0
	_top_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.06, 0.08, 0.94), 28, Color(0.2, 0.2, 0.24, 1.0)))
	add_child(_top_panel)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 22)
	top_margin.add_theme_constant_override("margin_top", 18)
	top_margin.add_theme_constant_override("margin_right", 22)
	top_margin.add_theme_constant_override("margin_bottom", 18)
	_top_panel.add_child(top_margin)

	var top_stack := VBoxContainer.new()
	top_stack.add_theme_constant_override("separation", 14)
	top_margin.add_child(top_stack)

	var title := Label.new()
	title.text = "Edit skin"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.98, 0.98, 0.99, 1.0))
	top_stack.add_child(title)

	var description := Label.new()
	description.text = "Choose a home style, then tap a room to preview individual floor finishes."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 18)
	description.add_theme_color_override("font_color", Color(0.84, 0.84, 0.88, 1.0))
	top_stack.add_child(description)

	var skin_scroll := ScrollContainer.new()
	skin_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	skin_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	skin_scroll.custom_minimum_size = Vector2(0.0, 118.0)
	top_stack.add_child(skin_scroll)

	_skin_buttons_root = HBoxContainer.new()
	_skin_buttons_root.add_theme_constant_override("separation", 12)
	skin_scroll.add_child(_skin_buttons_root)

	_room_panel = PanelContainer.new()
	_room_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_room_panel.anchor_left = 0.08
	_room_panel.anchor_right = 0.92
	_room_panel.anchor_top = 0.58
	_room_panel.anchor_bottom = 0.94
	_room_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.12, 0.14, 0.95), 28, Color(0.26, 0.26, 0.3, 1.0)))
	add_child(_room_panel)

	var room_margin := MarginContainer.new()
	room_margin.add_theme_constant_override("margin_left", 22)
	room_margin.add_theme_constant_override("margin_top", 18)
	room_margin.add_theme_constant_override("margin_right", 22)
	room_margin.add_theme_constant_override("margin_bottom", 18)
	_room_panel.add_child(room_margin)

	var room_stack := VBoxContainer.new()
	room_stack.add_theme_constant_override("separation", 14)
	room_margin.add_child(room_stack)

	_room_name_label = Label.new()
	_room_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_room_name_label.add_theme_font_size_override("font_size", 28)
	_room_name_label.add_theme_color_override("font_color", Color(0.98, 0.98, 0.99, 1.0))
	room_stack.add_child(_room_name_label)

	_room_hint_label = Label.new()
	_room_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_room_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_room_hint_label.add_theme_font_size_override("font_size", 16)
	_room_hint_label.add_theme_color_override("font_color", Color(0.84, 0.84, 0.88, 1.0))
	room_stack.add_child(_room_hint_label)

	_finish_buttons_root = HFlowContainer.new()
	_finish_buttons_root.add_theme_constant_override("h_separation", 12)
	_finish_buttons_root.add_theme_constant_override("v_separation", 12)
	room_stack.add_child(_finish_buttons_root)

	_apply_all_button = Button.new()
	_apply_all_button.text = "Apply to all rooms"
	_apply_all_button.custom_minimum_size = Vector2(0.0, 46.0)
	_apply_all_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.2, 0.2, 0.24, 1.0), 18, Color(0.34, 0.34, 0.4, 1.0)))
	_apply_all_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.24, 0.24, 0.28, 1.0), 18, Color(0.42, 0.42, 0.48, 1.0)))
	_apply_all_button.pressed.connect(func() -> void:
		emit_signal("apply_room_finish_to_all_requested")
	)
	room_stack.add_child(_apply_all_button)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	room_stack.add_child(actions)

	_cancel_button = Button.new()
	_cancel_button.text = "Cancel"
	_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cancel_button.custom_minimum_size = Vector2(0.0, 52.0)
	_cancel_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.18, 0.18, 0.2, 1.0), 18, Color(0.32, 0.32, 0.36, 1.0)))
	_cancel_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.22, 0.22, 0.24, 1.0), 18, Color(0.4, 0.4, 0.44, 1.0)))
	_cancel_button.pressed.connect(func() -> void:
		emit_signal("room_finish_cancel_requested")
	)
	actions.add_child(_cancel_button)

	_apply_button = Button.new()
	_apply_button.text = "Apply"
	_apply_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button.custom_minimum_size = Vector2(0.0, 52.0)
	_apply_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.22, 0.34, 0.68, 1.0), 18, Color(0.34, 0.54, 0.94, 1.0)))
	_apply_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.26, 0.4, 0.76, 1.0), 18, Color(0.44, 0.66, 1.0, 1.0)))
	_apply_button.pressed.connect(func() -> void:
		emit_signal("room_finish_apply_requested")
	)
	actions.add_child(_apply_button)


func _rebuild_home_skin_buttons(home_skin_models: Array) -> void:
	for child in _skin_buttons_root.get_children():
		child.queue_free()
	_skin_buttons.clear()

	var button_group := ButtonGroup.new()
	for skin_data in home_skin_models:
		if not skin_data is Dictionary:
			continue
		var model := skin_data as Dictionary
		var skin_id := String(model.get("id", ""))
		if skin_id.is_empty():
			continue
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = button_group
		button.custom_minimum_size = Vector2(120.0, 92.0)
		button.text = String(model.get("label", skin_id)).replace(" ", "\n")
		button.clip_text = false
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color(0.98, 0.98, 0.99, 1.0))
		button.add_theme_stylebox_override("normal", _make_panel_style(model.get("color", Color(0.28, 0.28, 0.32, 1.0)), 24, Color(0.42, 0.42, 0.46, 1.0)))
		button.add_theme_stylebox_override("hover", _make_panel_style((model.get("color", Color(0.3, 0.3, 0.34, 1.0)) as Color).lightened(0.06), 24, Color(0.52, 0.52, 0.58, 1.0)))
		button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.22, 0.44, 0.92, 1.0), 24, Color(0.6, 0.8, 1.0, 1.0), 3))
		button.pressed.connect(_on_skin_button_pressed.bind(skin_id))
		_skin_buttons_root.add_child(button)
		_skin_buttons[skin_id] = button


func _rebuild_finish_buttons(finish_models: Array) -> void:
	for child in _finish_buttons_root.get_children():
		child.queue_free()
	_finish_buttons.clear()

	var button_group := ButtonGroup.new()
	for finish_data in finish_models:
		if not finish_data is Dictionary:
			continue
		var model := finish_data as Dictionary
		var finish_id := String(model.get("id", ""))
		if finish_id.is_empty():
			continue
		var swatch_color := model.get("color", Color(0.78, 0.78, 0.78, 1.0)) as Color
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = button_group
		button.custom_minimum_size = Vector2(98.0, 82.0)
		button.text = String(model.get("label", finish_id)).replace(" ", "\n")
		button.add_theme_font_size_override("font_size", 16)
		button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.1, 1.0))
		button.add_theme_stylebox_override("normal", _make_panel_style(swatch_color, 20, Color(0.7, 0.7, 0.74, 1.0)))
		button.add_theme_stylebox_override("hover", _make_panel_style(swatch_color.lightened(0.08), 20, Color(0.84, 0.84, 0.9, 1.0)))
		button.add_theme_stylebox_override("pressed", _make_panel_style(swatch_color.lightened(0.16), 20, Color(0.26, 0.54, 1.0, 1.0), 3))
		button.pressed.connect(_on_finish_button_pressed.bind(finish_id))
		_finish_buttons_root.add_child(button)
		_finish_buttons[finish_id] = button

	_update_finish_button_states()


func _update_finish_button_states() -> void:
	for finish_id in _finish_buttons.keys():
		var button := _finish_buttons[finish_id] as Button
		if is_instance_valid(button):
			button.button_pressed = _has_selected_room and finish_id == _active_finish_id
			button.disabled = not _has_selected_room

	if is_instance_valid(_apply_all_button):
		_apply_all_button.disabled = not _has_selected_room
	if is_instance_valid(_cancel_button):
		_cancel_button.disabled = not _has_selected_room
	if is_instance_valid(_apply_button):
		_apply_button.disabled = not _has_selected_room


func _on_edit_button_pressed() -> void:
	emit_signal("edit_mode_requested", not _edit_mode)


func _on_skin_button_pressed(skin_id: String) -> void:
	emit_signal("home_skin_selected", skin_id)


func _on_finish_button_pressed(finish_id: String) -> void:
	if not _has_selected_room:
		return
	emit_signal("room_finish_preview_requested", finish_id)


func _make_panel_style(color: Color, radius: int, border_color: Color, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style
