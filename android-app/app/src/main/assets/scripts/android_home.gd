extends Node3D

const DEVICE_PIN_SCENE := preload("res://scenes/device_pin.tscn")
const DUST_PUFF_DRAMATIC_SCENE := preload("res://scenes/vfx/dust_puff_dramatic.tscn")
const DUST_PUFF_SCENE := preload("res://scenes/vfx/dust_puff.tscn")
const SHADER_WALL_MATERIAL_UNLIT := preload("res://shaders/wall_material_unlit.gdshader")
const SHADER_WALL_MATERIAL_DITHER_UNLIT := preload("res://shaders/wall_material_dither_unlit.gdshader")
const SHADER_FLOOR_MATERIAL_UNLIT := preload("res://shaders/floor_material_unlit.gdshader")
const SHADER_FURNITURE_DUAL_TONE_UNLIT := preload("res://shaders/furniture_dual_tone_unlit.gdshader")
const SHADER_FURNITURE_TWO_TONE_SHADOW := preload("res://shaders/furniture_two_tone_shadow.gdshader")
# Flip to false to restore the default lit pipeline. On-device preview flag.
const SHADER_PREVIEW_UNLIT_PACK_ENABLED := false
const FLOOR_PLAN_PATH := "res://data/sample_floor_plan.json"
const FLOOR_FINISH_STATE_PATH := "user://floor_finish_state.cfg"
const FLOOR_PLAN_SCALE := 0.04
const FLOOR_HEIGHT_SCALE := 0.022
const FLOOR_SURFACE_Y := 0.016
const LABEL_SURFACE_Y := 0.024
const WALL_THICKNESS := 0.14
const INTERIOR_WALL_HEIGHT := 2.35
const EXTERIOR_WALL_HEIGHT := 2.75
const FRONT_WALL_CUTAWAY_HEIGHT := 0.35
const WALL_TINT_WASH_INTERIOR := 0.38
const WALL_TINT_WASH_EXTERIOR := 0.55
const WALL_TINT_HIGHLIGHT := Color(0.98, 0.98, 0.99)
const EXTERIOR_WALL_COLOR := Color(0.84, 0.85, 0.83)
const PILL_FOCUS_FLOOR_COLOR := Color(0.30, 0.31, 0.33)
const PILL_FOCUS_WALL_EXTERIOR_COLOR := Color(0.97, 0.97, 0.97)
const PILL_FOCUS_WALL_INTERIOR_COLOR := Color(0.98, 0.98, 0.98)
const INTERIOR_WALL_ALPHA := 0.70
const PLATFORM_MARGIN := 0.34
const PLATFORM_HEIGHT := 0.07
const SHADOW_PLANE_Y := -0.043
const MARKER_HEIGHT := 0.055
const BASE_PLAN_ROTATION_Y := 0.0
const SMARTTHINGS_CAMERA_PITCH_DEG := 30.0
const SMARTTHINGS_CAMERA_DISTANCE_SCALE := 1.0
const ZOOM_3D_MIN_SCALE := 0.22
const ZOOM_3D_MAX_SCALE := 1.0
const ZOOM_OUT_OVERSCROLL_RANGE_FRACTION := 0.15
const ZOOM_SPRING_STIFFNESS := 26.0
const ZOOM_SPRING_DAMPING := 10.0
const ZOOM_SPRING_SNAP_DISTANCE := 0.0008
const ZOOM_SPRING_SNAP_SPEED := 0.0008
const VIEW_PADDING_3D := 1.08
const ROTATE_SNAP_STEP_DEG := 45.0
const DOUBLE_TAP_MAX_MS := 320
const DOUBLE_TAP_MAX_DISTANCE_PX := 40.0
const VIEW_PADDING_2D := 1.04
const SOFT_2D_CAMERA_FOV := 22.0
const SOFT_2D_MIN_FOV := 11.0
const SOFT_2D_MAX_FOV := 36.0
const SOFT_2D_PORTRAIT_HEIGHT := 2.12
const SOFT_2D_LANDSCAPE_HEIGHT := 1.86
const SOFT_2D_LOOK_OFFSET_Z := 0.10
const SOFT_2D_FOCUS_LIFT := 0.10
const CONTACT_SHADOW_ALPHA := 0.27
const CONTACT_SHADOW_SCALE := 2.6
const CONTACT_SHADOW_CORE_SCALE := 1.18
const CONTACT_SHADOW_MIN_SIZE := Vector2(0.66, 0.5)
const FURNITURE_TRANSPARENCY := 0.36
const FURNITURE_FLOOR_EPSILON := 0.0
const TAP_DISTANCE_THRESHOLD := 18.0
const PLAN_FOCUS_HEIGHT := 0.14
const PAN_START_DISTANCE_THRESHOLD := 8.0
const ZOOMED_OUT_PAN_EPSILON := 0.02
const TWO_FINGER_TURN_STEP_RADIANS := PI / 6.0
const FURNITURE_ROOM_EDGE_SNAP_DISTANCE := 0.8
const FURNITURE_ROOM_SNAP_INSET := 0.05
const FURNITURE_ROOM_EDGE_EPSILON := 0.002
const FURNITURE_GRID_STEP := 0.12
const FURNITURE_GRID_SEARCH_RINGS := 18
const FURNITURE_WALL_SNAP_DISTANCE := 1.28
const FURNITURE_WALL_CLEARANCE := 0.06
const FURNITURE_COLLISION_PADDING := 0.04
const FURNITURE_SELECTION_COLOR := Color(0.0, 0.36862746, 0.72156864, 1.0)
const FURNITURE_INVALID_COLOR := Color(1.0, 0.35, 0.35, 1.0)
const FURNITURE_SELECTION_BOX_PADDING_MIN := 0.008
const FURNITURE_SELECTION_BOX_PADDING_MAX := 0.024
const FURNITURE_SELECTION_BOX_PADDING_FRACTION := 0.03
const FURNITURE_SELECTION_OUTLINE_THICKNESS_MIN := 0.012
const FURNITURE_SELECTION_OUTLINE_THICKNESS_MAX := 0.028
const FURNITURE_SELECTION_OUTLINE_THICKNESS_FRACTION := 0.026
const FURNITURE_SELECTION_OUTLINE_HEIGHT := 0.045
const FURNITURE_ROTATE_HANDLE_RADIUS := 0.11
const FURNITURE_ROTATE_HANDLE_OFFSET := 0.18
const FURNITURE_HANDLE_ICON_SIZE := 128
const FURNITURE_HANDLE_PLANE_SIZE := 0.34
const FURNITURE_HANDLE_ELEVATION := 0.1
const FURNITURE_HANDLE_TAP_RADIUS := 58.0
const FURNITURE_TAP_EDGE_PADDING := 0.06
const FURNITURE_DUPLICATE_COMMIT_WINDOW_MS := 240
const FURNITURE_SCALE_MIN := 0.8
const FURNITURE_SCALE_MAX := 1.2
const FURNITURE_SCALE_STEP := 0.1
const ROOM_TAP_PADDING := 1.14
const DEVICE_PIN_TAP_RADIUS := 64.0
const DEVICE_PIN_PENDING_LOOP_DURATION := 0.52
const DEVICE_PIN_PENDING_LOOPS_REQUIRED := 8.0
const DEVICE_PIN_BOB_SPEED := 1.7
const DEVICE_PIN_BOB_AMPLITUDE := 0.01
const DEVICE_PIN_ZOOM_MIN_VISUAL_SCALE := 0.75
const DEVICE_PIN_ZOOM_COMPENSATION_RANGE := 0.78
const DEVICE_PIN_BASE_SCALE := 0.62
const DEVICE_PIN_ON_COLOR := Color(1.0, 0.8, 0.29, 1.0)
const DEVICE_PIN_COOL_COLOR := Color(0.56, 0.83, 1.0, 1.0)
const DEVICE_PIN_AIR_PURIFIER_COLOR := Color(0.58, 0.88, 0.66, 1.0)
const DEVICE_PIN_LIGHT_ICON_PATH := "res://SmartThingsIcons/Light_1.png"
const DEVICE_PIN_AIR_CONDITIONER_ICON_PATH := "res://SmartThingsIcons/Air_Conditioner_2.png"
const DEVICE_PIN_AIR_PURIFIER_ICON_PATH := "res://SmartThingsIcons/Air_Purifier.png"
const DEVICE_PIN_CAMERA_ICON_PATH := "res://SmartThingsIcons/Camera_1.png"
const DEVICE_PIN_CAMERA_COLOR := Color(0.75, 0.88, 1.0, 1.0)
const CAMERA_LIVING_ROOM_IMAGE_PATH := "res://assets/camera_images/living_room.jpeg"
const CAMERA_CALLOUT_ASSET_PATH := "assets/camera_images/living_room.jpeg"

const CAMERA_CALLOUT_ANCHOR_Y := 1.5
const CAMERA_CALLOUT_IMAGE_SIZE := Vector2(600, 400)
const CAMERA_CALLOUT_PADDING := 12.0
const CAMERA_CALLOUT_POINTER_HEIGHT := 26.0
const CAMERA_CALLOUT_POINTER_HALF_BASE := 18.0

const ENERGY_CALLOUT_VIEWPORT_SIZE := Vector2i(520, 220)
const ENERGY_CALLOUT_PIXEL_SIZE := 0.004
const ENERGY_CALLOUT_ANCHOR_Y := 1.5
const ENERGY_CALLOUT_BUBBLE_SIZE := Vector2(460, 170)
const ENERGY_CALLOUT_LABEL_FONT_SIZE := 84
const ENERGY_CALLOUT_ICON_PLUG_PATH := "res://SmartThingsIcons/Smart_Plug.png"
const ENERGY_CALLOUT_ICON_ENERGY_PATH := "res://SmartThingsIcons/Energy_Monitoring.png"
const ENERGY_CALLOUT_STAGGER_MIN := 0.025
const ENERGY_CALLOUT_STAGGER_MAX := 0.055
const DEVICE_AIR_CONDITIONER_MODEL_CANDIDATE_PATHS := [
	"res://GLB/AC.glb",
	"res://GLB/ac.glb",
	"res://GLB/air_conditioner.glb",
	"res://GLB/Air_Conditioner.glb",
	"res://GLB/air_conditioner_wall.glb",
]
const AIR_CONDITIONER_TARGET_SIZE := Vector3(0.62, 0.19, 0.16)
const AIR_CONDITIONER_WALL_HEIGHT := 0.44
const AIR_CONDITIONER_WALL_CLEARANCE := 0.028
const AIR_CONDITIONER_FALLBACK_COLOR := Color(0.95, 0.97, 1.0, 1.0)
const AIR_CONDITIONER_FALLBACK_PANEL_COLOR := Color(0.84, 0.9, 0.96, 1.0)
const AIR_CONDITIONER_FALLBACK_VENT_COLOR := Color(0.62, 0.72, 0.82, 1.0)
const DEVICE_TEMPERATURE_DEFAULT_C := 24
const SAMPLE_HOME_DEVICE_ROOMS := ["Living", "Kitchen", "Master", "Study", "Bedroom"]
const DEVICE_KIND_LIGHT := "light"
const DEVICE_KIND_AIR_CONDITIONER := "air_conditioner"
const DEVICE_KIND_AIR_PURIFIER := "air_purifier"
const DEVICE_KIND_CAMERA := "camera"
const AIR_QUALITY_GOOD := "good"
const AIR_QUALITY_BAD := "bad"
const AIR_QUALITY_VERY_BAD := "very_bad"
const APP_PLUGIN_NAME := "SmartHomeAppPlugin"
const SIGNAL_LIGHT_FOCUS_MODE_CHANGED := "light_focus_mode_changed"
const SIGNAL_TEMPERATURE_FOCUS_MODE_CHANGED := "temperature_focus_mode_changed"
const SIGNAL_AIR_QUALITY_FOCUS_MODE_CHANGED := "air_quality_focus_mode_changed"
const SIGNAL_CAMERA_FOCUS_MODE_CHANGED := "camera_focus_mode_changed"
const SIGNAL_ENERGY_FOCUS_MODE_CHANGED := "energy_focus_mode_changed"
const SIGNAL_FLOOR_PLAN_EDIT_MODE_CHANGED := "floor_plan_edit_mode_changed"
const SIGNAL_FURNITURE_EDIT_MODE_CHANGED := "furniture_edit_mode_changed"
const SIGNAL_HOME_SKIN_SELECTED := "home_skin_selected"
const SIGNAL_ROOM_FINISH_PREVIEW_REQUESTED := "room_finish_preview_requested"
const SIGNAL_ROOM_FINISH_APPLY_TO_ALL_REQUESTED := "room_finish_apply_to_all_requested"
const SIGNAL_ROOM_FINISH_APPLY_REQUESTED := "room_finish_apply_requested"
const SIGNAL_ROOM_FINISH_CANCEL_REQUESTED := "room_finish_cancel_requested"
const SIGNAL_FLOOR_PLAN_SESSION_APPLY_REQUESTED := "floor_plan_session_apply_requested"
const SIGNAL_FLOOR_PLAN_SESSION_CANCEL_REQUESTED := "floor_plan_session_cancel_requested"
const SIGNAL_DEVICE_COMMAND_REQUESTED := "device_command_requested"
# Accessibility (TalkBack) signals — emitted by ShaderHostPlugin.kt when
# TalkBack moves focus or activates a virtual node in the overlay.
const SIGNAL_ACCESSIBILITY_FOCUS_CHANGED := "accessibility_focus_changed"
const SIGNAL_ACCESSIBILITY_ACTIVATE := "accessibility_activate"
# Preloaded so we don't depend on `class_name` registration timing during
# project load (Godot otherwise reports "Identifier not declared in scope").
const AccessibilityTreeBuilder := preload("res://scripts/accessibility_tree_builder.gd")
const JAVA_METHOD_PUBLISH_ACCESSIBILITY_TREE := "publishAccessibilityTree"
const JAVA_METHOD_ANNOUNCE_FOR_ACCESSIBILITY := "announceForAccessibility"
const JAVA_METHOD_SHOW_DEVICE_CONTROL_POPUP := "showDeviceControlPopup"
const JAVA_METHOD_NOTIFY_LIGHT_STATUS := "notifyLightStatus"
const JAVA_METHOD_NOTIFY_TEMPERATURE_STATUS := "notifyTemperatureStatus"
const JAVA_METHOD_SHOW_CAMERA_CALLOUT := "showCameraCallout"
const JAVA_METHOD_NOTIFY_ENERGY_SUMMARY := "notifyEnergySummary"
const JAVA_METHOD_SHOW_FLOOR_EDITOR_SELECTION := "showFloorEditorSelection"
const JAVA_METHOD_CLEAR_FLOOR_EDITOR_SELECTION := "clearFloorEditorSelection"
const JAVA_METHOD_CLEAR_FURNITURE_CATALOG_SELECTION := "clearFurnitureCatalogSelection"

const IKEA_FURNITURE_MANIFEST_PATH := "res://GLB/ikea/manifest.json"
const MODEL_KIND_BED := "bed"
const MODEL_KIND_CABINET := "cabinet"
const MODEL_KIND_TABLE := "table"
const MODEL_KIND_STEP_STOOL := "step_stool"
const MODEL_KIND_SEAT := "seat"
const MODEL_KIND_SOFA := "sofa"
# Sofa-only catalog. The sample app intentionally ships with just these five
# GLBs (sofa_1..sofa_5) so the two-tone shadow shader has a consistent set of
# silhouettes to demonstrate the SmartThings VI guideline aesthetic. Each
# sofa is rendered with the room's floor colour fed straight into the shader.
const SOFA_VARIANT_IDS := [
	"sofa_1",
	"sofa_2",
	"sofa_3",
	"sofa_4",
	"sofa_5",
]
const LEGACY_MODEL_DEFINITIONS := [
	{
		"id": "sofa_1",
		"asset_path": "res://GLB/sofas/sofa_1.glb",
		"kind": MODEL_KIND_SOFA,
		"base_scale": 1.0,
		"floor_offset": 0.0,
		"shadow_footprint": Vector2(2.6, 1.9),
	},
	{
		"id": "sofa_2",
		"asset_path": "res://GLB/sofas/sofa_2.glb",
		"kind": MODEL_KIND_SOFA,
		"base_scale": 1.0,
		"floor_offset": 0.0,
		"shadow_footprint": Vector2(2.6, 1.9),
	},
	{
		"id": "sofa_3",
		"asset_path": "res://GLB/sofas/sofa_3.glb",
		"kind": MODEL_KIND_SOFA,
		"base_scale": 1.0,
		"floor_offset": 0.0,
		"shadow_footprint": Vector2(2.6, 1.9),
	},
	{
		"id": "sofa_4",
		"asset_path": "res://GLB/sofas/sofa_4.glb",
		"kind": MODEL_KIND_SOFA,
		"base_scale": 1.0,
		"floor_offset": 0.0,
		"shadow_footprint": Vector2(2.6, 1.9),
	},
	{
		"id": "sofa_5",
		"asset_path": "res://GLB/sofas/sofa_5.glb",
		"kind": MODEL_KIND_SOFA,
		"base_scale": 1.0,
		"floor_offset": 0.0,
		"shadow_footprint": Vector2(2.6, 1.9),
	},
]

const ROOM_FURNITURE_LIMITS := {
	"BEDROOM": 1,
	"KITCHEN": 2,
	"BATHROOM": 1,
	"CLOSET": 1,
}

const SAMPLE_HOME_DEVICE_LAYOUT := {
	"Living": [
		{
			"id": "living_light",
			"name": "Living Light",
			"icon_path": DEVICE_PIN_LIGHT_ICON_PATH,
			"accent_color": DEVICE_PIN_ON_COLOR,
			"kind": DEVICE_KIND_LIGHT,
			"offset": Vector2(0.0, 0.08),
			"is_on": true,
		},
		{
			"id": "living_ac",
			"name": "Living AC",
			"icon_path": DEVICE_PIN_AIR_CONDITIONER_ICON_PATH,
			"accent_color": DEVICE_PIN_COOL_COLOR,
			"kind": DEVICE_KIND_AIR_CONDITIONER,
			"offset": Vector2(0.26, -0.34),
			"is_on": true,
			"temperature_c": 19,
		},
		{
			"id": "living_camera",
			"name": "Living Camera",
			"icon_path": DEVICE_PIN_CAMERA_ICON_PATH,
			"accent_color": DEVICE_PIN_CAMERA_COLOR,
			"kind": DEVICE_KIND_CAMERA,
			"offset": Vector2(-0.22, -0.22),
			"is_on": true,
			"image_path": CAMERA_LIVING_ROOM_IMAGE_PATH,
			"image_asset": CAMERA_CALLOUT_ASSET_PATH,
		},
	],
	"Kitchen": [
		{
			"id": "kitchen_light",
			"name": "Kitchen Light",
			"icon_path": DEVICE_PIN_LIGHT_ICON_PATH,
			"accent_color": DEVICE_PIN_ON_COLOR,
			"kind": DEVICE_KIND_LIGHT,
			"offset": Vector2(0.14, 0.02),
			"is_on": true,
		},
	],
	"Master": [
		{
			"id": "master_light",
			"name": "Master Light",
			"icon_path": DEVICE_PIN_LIGHT_ICON_PATH,
			"accent_color": DEVICE_PIN_ON_COLOR,
			"kind": DEVICE_KIND_LIGHT,
			"offset": Vector2(0.02, 0.06),
			"is_on": true,
		},
	],
	"Study": [
		{
			"id": "study_light",
			"name": "Study Light",
			"icon_path": DEVICE_PIN_LIGHT_ICON_PATH,
			"accent_color": DEVICE_PIN_ON_COLOR,
			"kind": DEVICE_KIND_LIGHT,
			"offset": Vector2(0.18, 0.08),
			"is_on": false,
		},
		{
			"id": "study_ac",
			"name": "Study AC",
			"icon_path": DEVICE_PIN_AIR_CONDITIONER_ICON_PATH,
			"accent_color": DEVICE_PIN_COOL_COLOR,
			"kind": DEVICE_KIND_AIR_CONDITIONER,
			"offset": Vector2(-0.3, -0.34),
			"is_on": true,
			"temperature_c": 23,
		},
	],
	"Bedroom": [
		{
			"id": "bedroom_light",
			"name": "Bedroom Light",
			"icon_path": DEVICE_PIN_LIGHT_ICON_PATH,
			"accent_color": DEVICE_PIN_ON_COLOR,
			"kind": DEVICE_KIND_LIGHT,
			"offset": Vector2(0.16, 0.08),
			"is_on": false,
		},
		{
			"id": "bedroom_ac",
			"name": "Bedroom AC",
			"icon_path": DEVICE_PIN_AIR_CONDITIONER_ICON_PATH,
			"accent_color": DEVICE_PIN_COOL_COLOR,
			"kind": DEVICE_KIND_AIR_CONDITIONER,
			"offset": Vector2(0.28, -0.34),
			"is_on": true,
			"temperature_c": 27,
		},
	],
}

const SAMPLE_HOME_AIR_PURIFIER_LAYOUT := [
	{
		"id": "living_air_purifier",
		"room_label": "Living",
		"offset": Vector2(0.08, 0.16),
		"quality_state": AIR_QUALITY_GOOD,
	},
	{
		"id": "master_air_purifier",
		"room_label": "Master",
		"offset": Vector2(0.14, 0.2),
		"quality_state": AIR_QUALITY_BAD,
	},
	{
		"id": "bath_air_purifier",
		"room_category": "BATHROOM",
		"room_selector": "rightmost",
		"offset": Vector2(-0.08, 0.16),
		"quality_state": AIR_QUALITY_VERY_BAD,
	},
]

const FLOOR_FINISH_ORDER := [
	"solid_neutral",
	"solid_warm",
	"solid_cool",
	"color_living",
	"color_kitchen",
	"color_bedroom",
	"color_bath",
	"color_accent",
	"oak_light",
	"oak_dark",
	"herringbone_beige",
	"tile_rect_beige",
	"zigzag_taupe",
	"grid_ash",
	"marble_white",
	"tile_soft_gray",
]

const FLOOR_FINISHES := {
	"solid_neutral": {
		"label": "Soft Gray",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.44, 0.46, 0.50),
		"world_triplanar": false,
		"solid_color": Color(0.44, 0.46, 0.50),
	},
	"solid_warm": {
		"label": "Warm Sand",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.82, 0.76, 0.66),
		"world_triplanar": false,
		"solid_color": Color(0.82, 0.76, 0.66),
	},
	"solid_cool": {
		"label": "Cool Mist",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.70, 0.75, 0.80),
		"world_triplanar": false,
		"solid_color": Color(0.70, 0.75, 0.80),
	},
	"color_living": {
		"label": "Sage",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.70, 0.84, 0.64),
		"world_triplanar": false,
		"solid_color": Color(0.70, 0.84, 0.64),
	},
	"color_kitchen": {
		"label": "Butter",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.96, 0.88, 0.56),
		"world_triplanar": false,
		"solid_color": Color(0.96, 0.88, 0.56),
	},
	"color_bedroom": {
		"label": "Rose",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.92, 0.72, 0.78),
		"world_triplanar": false,
		"solid_color": Color(0.92, 0.72, 0.78),
	},
	"color_bath": {
		"label": "Mint",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.66, 0.88, 0.85),
		"world_triplanar": false,
		"solid_color": Color(0.66, 0.88, 0.85),
	},
	"color_accent": {
		"label": "Lavender",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 1.0,
		"swatch_color": Color(0.78, 0.74, 0.92),
		"world_triplanar": false,
		"solid_color": Color(0.78, 0.74, 0.92),
	},
	"oak_light": {
		"label": "Oak Light",
		"material": preload("res://materials/floors/oak_light.tres"),
		"uv_scale": 0.68,
		"swatch_color": Color(0.92, 0.84, 0.74),
		"world_triplanar": false,
	},
	"oak_dark": {
		"label": "Oak Dark",
		"material": preload("res://materials/floors/oak_dark.tres"),
		"uv_scale": 0.68,
		"swatch_color": Color(0.53, 0.41, 0.31),
		"world_triplanar": false,
	},
	"herringbone_beige": {
		"label": "Herringbone Beige",
		"material": preload("res://materials/floors/herringbone_beige.tres"),
		"uv_scale": 0.84,
		"swatch_color": Color(0.83, 0.77, 0.69),
		"world_triplanar": false,
	},
	"tile_rect_beige": {
		"label": "Rectangle Tile",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 0.92,
		"swatch_color": Color(0.87, 0.83, 0.77),
		"world_triplanar": false,
		"pattern_id": "rectangles",
		"pattern_base_color": Color(0.87, 0.83, 0.77),
		"pattern_line_color": Color(0.77, 0.73, 0.68),
	},
	"zigzag_taupe": {
		"label": "Zig Zag",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 0.88,
		"swatch_color": Color(0.8, 0.75, 0.7),
		"world_triplanar": false,
		"pattern_id": "zigzag",
		"pattern_base_color": Color(0.8, 0.75, 0.7),
		"pattern_line_color": Color(0.69, 0.64, 0.59),
	},
	"grid_ash": {
		"label": "Grid Tile",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 0.76,
		"swatch_color": Color(0.77, 0.79, 0.8),
		"world_triplanar": false,
		"pattern_id": "grid",
		"pattern_base_color": Color(0.77, 0.79, 0.8),
		"pattern_line_color": Color(0.66, 0.69, 0.72),
	},
	"marble_white": {
		"label": "Marble White",
		"material": preload("res://materials/floors/marble_white.tres"),
		"uv_scale": 0.58,
		"swatch_color": Color(0.93, 0.93, 0.95),
		"world_triplanar": true,
	},
	"tile_soft_gray": {
		"label": "Tile Soft Gray",
		"material": preload("res://materials/floors/tile_soft_gray.tres"),
		"uv_scale": 0.94,
		"swatch_color": Color(0.78, 0.81, 0.84),
		"world_triplanar": true,
	},
}

const HOME_SKIN_ORDER := [
	"color_default",
	"solid_default",
	"warm_minimal",
	"cool_modern",
	"soft_contrast",
]

const HOME_SKINS := {
	"color_default": {
		"label": "Color Rooms",
		"color": Color(0.78, 0.84, 0.72),
		"mapping": {
			"living": "color_living",
			"bedroom": "color_bedroom",
			"kitchen": "color_kitchen",
			"bath": "color_bath",
			"accent": "color_accent",
		},
	},
	"solid_default": {
		"label": "Solid Color",
		"color": Color(0.78, 0.78, 0.82),
		"mapping": {
			"living": "solid_neutral",
			"bedroom": "solid_neutral",
			"kitchen": "solid_neutral",
			"bath": "solid_neutral",
			"accent": "solid_neutral",
		},
	},
	"warm_minimal": {
		"label": "Warm Minimal",
		"color": Color(0.41, 0.33, 0.27),
		"mapping": {
			"living": "herringbone_beige",
			"bedroom": "oak_light",
			"kitchen": "tile_rect_beige",
			"bath": "marble_white",
			"accent": "oak_dark",
		},
	},
	"cool_modern": {
		"label": "Cool Modern",
		"color": Color(0.25, 0.3, 0.38),
		"mapping": {
			"living": "oak_dark",
			"bedroom": "oak_dark",
			"kitchen": "grid_ash",
			"bath": "marble_white",
			"accent": "grid_ash",
		},
	},
	"soft_contrast": {
		"label": "Soft Contrast",
		"color": Color(0.3, 0.38, 0.28),
		"mapping": {
			"living": "zigzag_taupe",
			"bedroom": "oak_light",
			"kitchen": "marble_white",
			"bath": "grid_ash",
			"accent": "oak_dark",
		},
	},
}

@onready var _skin_editor_ui = $CanvasLayer/SkinEditorUI

var _camera: Camera3D
var _home_pivot: Node3D
var _floor_nodes: Array[MeshInstance3D] = []
var _wall_nodes: Array[MeshInstance3D] = []
var _wall_tint_entries: Array[Dictionary] = []
var _exterior_wall_records: Array[Dictionary] = []
var _door_segments: Array[Dictionary] = []
var _label_nodes: Array[Node3D] = []
var _furniture_roots: Array[Node3D] = []
var _device_pins := {}
var _device_pin_order: Array[String] = []
var _focus_material_entries: Array[Dictionary] = []
var _light_focus_active := false
var _temperature_focus_active := false
var _air_quality_focus_active := false
var _camera_focus_active := false
var _energy_focus_active := false
var _selected_air_quality_device_id := ""
var _app_plugin_connected := false
# --- Accessibility / TalkBack ---
# True once we've successfully published at least one tree, so we don't fire a
# stale republish on every camera tick before _ready finishes setting up rooms.
var _a11y_initial_publish_done := false
# Debounce timer for tree republish — see _publish_accessibility_tree_debounced().
# Single-shot, recreated on demand.
var _a11y_publish_timer: SceneTreeTimer = null
# The accessibility node id TalkBack last reported as focused. Used to avoid
# redundant focus mode transitions when TalkBack briefly moves focus during
# a tree republish.
var _a11y_focused_node_id := ""
# Currently published floor name (for the floor:<name> id).
var _a11y_floor_name := ""
# Cached transforms used to detect when the camera or pivot has moved enough
# to warrant republishing the tree (debounced). Comparing every frame is
# cheap; the actual JSON serialisation only runs after the 50 ms debounce.
var _a11y_last_camera_origin := Vector3.INF
var _a11y_last_camera_basis_x := Vector3.INF
var _a11y_last_pivot_rotation_y := INF
var _a11y_last_zoom_scale := -1.0
var _world_environment: WorldEnvironment = null
var _camera_callout_nodes := {}
var _camera_overlay_layer: CanvasLayer = null
var _energy_callout_nodes := {}
var _energy_focus_token := 0
var _last_single_camera_device_id := ""
var _energy_plug_icon: Texture2D = null
var _energy_bolt_icon: Texture2D = null
var _plan_bounds := Rect2(Vector2.ZERO, Vector2(8.8, 6.0))
var _plan_size := Vector2(8.8, 6.0)
var _plan_center_raw := Vector2.ZERO
var _plan_focus := Vector3.ZERO
var _room_entries: Array[Dictionary] = []
var _is_3d_view := true
var _zoom_scale := 1.0
var _zoom_rest_scale := 1.0
var _zoom_velocity := 0.0
var _base_camera_size := 10.0
var _base_camera_fov := SOFT_2D_CAMERA_FOV
var _angle_index := 0
var _touch_points := {}
var _touch_start_points := {}
var _touch_max_movement := {}
var _pinch_distance := 0.0
var _pinch_start_zoom_scale := 1.0
var _pinch_angle := 0.0
var _pinch_rotation_accum := 0.0
var _pinch_active := false
var _last_tap_time_ms := 0
var _last_tap_position := Vector2.ZERO
var _suppress_single_touch_until_release := false
var _pan_touch_index := -1
var _pan_touch_active := false
var _contact_shadow_texture: Texture2D
var _room_selection_overlay: StandardMaterial3D
var _floor_pattern_texture_cache: Dictionary = {}
var _focus_grayscale_texture_cache: Dictionary = {}
var _model_layout_cache: Dictionary = {}
var _model_paths: Dictionary = {}
var _model_scales: Dictionary = {}
var _model_floor_offsets: Dictionary = {}
var _model_shadow_footprints: Dictionary = {}
var _model_kinds: Dictionary = {}
var _default_model_ids_by_kind: Dictionary = {}
var _furniture_handle_texture_cache: Dictionary = {}
var _selected_room_id: String = ""
var _edit_mode := false
var _furniture_edit_mode := false
var _active_home_skin_id := "color_default"
var _pending_home_skin_id := "solid_default"
var _rooms_by_id: Dictionary = {}
var _edit_mode_restore_rotation_y := BASE_PLAN_ROTATION_Y
var _placement_model_id := ""
var _placement_touch_index := -1
var _placement_mouse_pressed := false
var _placement_mouse_press_position := Vector2.ZERO
var _placement_mouse_drag_distance := 0.0
var _placement_preview_root: Node3D
var _placement_preview_room_id := ""
var _placement_preview_rotation_y := 0.0
var _placement_last_screen_position := Vector2.INF
var _placement_drag_active := false
var _placement_grid_offsets: Array[Vector2] = []
var _selected_furniture_root: Node3D
var _selected_furniture_touch_index := -1
var _selected_furniture_mouse_pressed := false
var _selected_furniture_interaction := ""
var _selected_furniture_drag_active := false
var _selected_furniture_last_valid_surface: Dictionary = {}
var _selected_furniture_last_valid_scale_factor := 1.0
var _selected_furniture_resize_start_scale_factor := 1.0
var _selected_furniture_resize_start_distance := 0.0
var _last_furniture_commit_time_msec := 0
var _last_furniture_commit_point := Vector2.INF


func _ready() -> void:
	_configure_furniture_catalog()
	_build_scene()
	_build_floor_plan()
	_setup_skin_editor_ui()
	_connect_app_plugin()
	call_deferred("_log_device_pin_screen_positions")
	_notify_light_status()
	_notify_temperature_status()
	_refresh_annotation_visibility()
	_update_camera_for_viewport()
	call_deferred("_play_intro_animation")


func _play_intro_animation() -> void:
	if _edit_mode or not _is_3d_view:
		return
	var target_rotation := BASE_PLAN_ROTATION_Y
	var target_zoom := _current_zoom_max_scale()
	_home_pivot.rotation_degrees.y = target_rotation - 14.0
	_set_zoom_scale_immediate(clampf(target_zoom * 0.72, _current_zoom_min_scale(), target_zoom))
	_update_camera_for_viewport()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_home_pivot, "rotation_degrees:y", target_rotation, 1.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_zoom_scale_immediate, _zoom_scale, target_zoom, 1.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED and is_instance_valid(_camera):
		_update_camera_for_viewport()
		# Viewport size changed → all bounds in the published a11y tree are
		# stale. Republish so TalkBack focus rectangles realign.
		if _a11y_initial_publish_done:
			_publish_accessibility_tree_debounced()


func _configure_furniture_catalog() -> void:
	_model_paths.clear()
	_model_scales.clear()
	_model_floor_offsets.clear()
	_model_shadow_footprints.clear()
	_model_kinds.clear()
	_default_model_ids_by_kind.clear()
	_model_layout_cache.clear()

	for definition in LEGACY_MODEL_DEFINITIONS:
		_register_furniture_model(
			String(definition.get("id", "")),
			String(definition.get("asset_path", "")),
			String(definition.get("kind", MODEL_KIND_SOFA)),
			float(definition.get("base_scale", 1.0)),
			float(definition.get("floor_offset", 0.0)),
			definition.get("shadow_footprint", Vector2(CONTACT_SHADOW_SCALE, CONTACT_SHADOW_SCALE)) as Vector2
		)

	# Sample app deliberately uses only the sofa GLB set, so the IKEA
	# manifest is no longer ingested. Re-enable the loop below if a richer
	# catalog is ever needed.

	print("[SmartHome] Furniture catalog configured with %d models" % _model_paths.size())


func _load_ikea_furniture_manifest_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	if not FileAccess.file_exists(IKEA_FURNITURE_MANIFEST_PATH):
		return items
	var file := FileAccess.open(IKEA_FURNITURE_MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return items
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return items
	var raw_items: Variant = parsed.get("items", [])
	if not (raw_items is Array):
		return items
	for raw_item in raw_items:
		if raw_item is Dictionary:
			items.append(raw_item)
	return items


func _register_furniture_model(
	model_id: String,
	asset_path: String,
	kind: String,
	base_scale: float = 1.0,
	floor_offset: float = 0.0,
	shadow_footprint := Vector2(CONTACT_SHADOW_SCALE, CONTACT_SHADOW_SCALE),
) -> void:
	if model_id.is_empty() or asset_path.is_empty():
		return
	_model_paths[model_id] = asset_path
	_model_scales[model_id] = base_scale
	_model_floor_offsets[model_id] = floor_offset
	_model_shadow_footprints[model_id] = shadow_footprint
	_model_kinds[model_id] = kind
	if String(_default_model_ids_by_kind.get(kind, "")).is_empty():
		_default_model_ids_by_kind[kind] = model_id


func _furniture_model_kind(model_id: String, product_name := "") -> String:
	var lowered := ("%s %s" % [model_id, product_name]).to_lower()
	if lowered.contains("bed") or lowered.contains("divan"):
		return MODEL_KIND_BED
	if lowered.contains("wardrobe") or lowered.contains("cabinet") or lowered.contains("closet"):
		return MODEL_KIND_CABINET
	if lowered.contains("table") or lowered.contains("desk"):
		return MODEL_KIND_TABLE
	if lowered.contains("step-stool") or (lowered.contains("step") and lowered.contains("stool")):
		return MODEL_KIND_STEP_STOOL
	return MODEL_KIND_SEAT


func _default_model_scale_for_kind(_kind: String) -> float:
	return 1.0


func _default_model_floor_offset_for_kind(_kind: String) -> float:
	return 0.0


func _default_model_shadow_footprint_for_kind(kind: String) -> Vector2:
	match kind:
		MODEL_KIND_BED:
			return Vector2(1.42, 1.28)
		MODEL_KIND_CABINET:
			return Vector2(1.12, 1.08)
		MODEL_KIND_TABLE:
			return Vector2(1.22, 1.16)
		MODEL_KIND_STEP_STOOL:
			return Vector2(1.26, 1.14)
		MODEL_KIND_SEAT:
			return Vector2(1.08, 1.04)
		MODEL_KIND_SOFA:
			return Vector2(1.34, 1.10)
		_:
			return Vector2(CONTACT_SHADOW_SCALE, CONTACT_SHADOW_SCALE)


func _default_model_id_for_kind(kind: String, fallback := "") -> String:
	var model_id := String(_default_model_ids_by_kind.get(kind, ""))
	if not model_id.is_empty():
		return model_id
	if not fallback.is_empty() and _model_paths.has(fallback):
		return fallback
	for available_model_id in _model_paths.keys():
		return String(available_model_id)
	return fallback


func _setup_skin_editor_ui() -> void:
	if not is_instance_valid(_skin_editor_ui):
		return
	_skin_editor_ui.visible = false
	var edit_mode_requested := Callable(self, "_on_skin_editor_edit_mode_requested")
	var home_skin_selected := Callable(self, "_on_home_skin_selected")
	var room_finish_preview_requested := Callable(self, "_on_room_finish_preview_requested")
	var room_finish_apply_requested := Callable(self, "_on_room_finish_apply_requested")
	var room_finish_cancel_requested := Callable(self, "_on_room_finish_cancel_requested")
	var apply_room_finish_to_all_requested := Callable(self, "_on_apply_room_finish_to_all_requested")
	_skin_editor_ui.configure(_home_skin_ui_models(), _floor_finish_ui_models())
	if not _skin_editor_ui.edit_mode_requested.is_connected(edit_mode_requested):
		_skin_editor_ui.edit_mode_requested.connect(edit_mode_requested)
	if not _skin_editor_ui.home_skin_selected.is_connected(home_skin_selected):
		_skin_editor_ui.home_skin_selected.connect(home_skin_selected)
	if not _skin_editor_ui.room_finish_preview_requested.is_connected(room_finish_preview_requested):
		_skin_editor_ui.room_finish_preview_requested.connect(room_finish_preview_requested)
	if not _skin_editor_ui.room_finish_apply_requested.is_connected(room_finish_apply_requested):
		_skin_editor_ui.room_finish_apply_requested.connect(room_finish_apply_requested)
	if not _skin_editor_ui.room_finish_cancel_requested.is_connected(room_finish_cancel_requested):
		_skin_editor_ui.room_finish_cancel_requested.connect(room_finish_cancel_requested)
	if not _skin_editor_ui.apply_room_finish_to_all_requested.is_connected(apply_room_finish_to_all_requested):
		_skin_editor_ui.apply_room_finish_to_all_requested.connect(apply_room_finish_to_all_requested)
	_skin_editor_ui.set_active_skin(_active_home_skin_id)
	_skin_editor_ui.set_edit_mode(false)
	_skin_editor_ui.clear_selected_room()


func _process(delta: float) -> void:
	if not _app_plugin_connected:
		_connect_app_plugin()

	_update_zoom_spring(delta)
	_update_camera_callout_positions()
	_check_accessibility_camera_dirty()

	if _device_pin_order.is_empty():
		return
	var time := Time.get_ticks_msec() * 0.001
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if device.is_empty():
			continue
		var bob_offset := sin(time * DEVICE_PIN_BOB_SPEED + float(device.get("phase", 0.0))) * DEVICE_PIN_BOB_AMPLITUDE
		var pin: Variant = _device_pin_instance(device)
		if pin != null:
			pin.set_bob_offset(bob_offset)
		if int(device.get("pending_target", -1)) != -1:
			var pending_progress := float(device.get("pending_progress", 0.0)) + delta / DEVICE_PIN_PENDING_LOOP_DURATION
			device["pending_progress"] = pending_progress
			_device_pins[device_id] = device
			if pin != null:
				pin.set_pending_progress(pending_progress)
			if pending_progress >= DEVICE_PIN_PENDING_LOOPS_REQUIRED:
				_confirm_device_state_change(
					device_id,
					bool(int(device.get("pending_target", 0))),
					int(device.get("request_token", 0))
				)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		if _edit_mode:
			return
		if event.factor > 0.0:
			_apply_zoom_scale(_zoom_scale / event.factor, true)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
			_touch_start_points[event.index] = event.position
			_touch_max_movement[event.index] = 0.0
			if _touch_points.size() == 1:
				_pan_touch_index = event.index
				_pan_touch_active = false
			if _touch_points.size() == 2:
				_placement_touch_index = -1
				_selected_furniture_touch_index = -1
				_selected_furniture_interaction = ""
				_selected_furniture_drag_active = false
				_pan_touch_index = -1
				_pan_touch_active = false
				_begin_pinch_gesture()
				return
			if _suppress_single_touch_until_release:
				return
			if _is_placement_active() and _touch_points.size() == 1:
				_placement_touch_index = event.index
				_placement_drag_active = false
				_update_furniture_preview(event.position)
				return
			if _is_furniture_edit_active() and _touch_points.size() == 1:
				var screen_position: Vector2 = event.position
				var floor_point := _screen_to_floor(event.position)
				if _selected_furniture_delete_handle_contains(screen_position):
					_selected_furniture_touch_index = event.index
					_selected_furniture_interaction = "delete"
					_selected_furniture_drag_active = false
					return
				if _selected_furniture_resize_handle_contains(screen_position):
					if floor_point == Vector2.INF:
						return
					_selected_furniture_touch_index = event.index
					_selected_furniture_interaction = "resize"
					_selected_furniture_drag_active = false
					_selected_furniture_resize_start_scale_factor = _current_furniture_scale_factor(_selected_furniture_root)
					_selected_furniture_resize_start_distance = maxf(
						floor_point.distance_to(_furniture_center_2d(_selected_furniture_root)),
						0.001
					)
					return
				if _selected_furniture_handle_contains(screen_position):
					_selected_furniture_touch_index = event.index
					_selected_furniture_interaction = "rotate"
					return
				if floor_point != Vector2.INF:
					var furniture_root := _find_furniture_root_at_point(floor_point)
					if is_instance_valid(furniture_root):
						_set_selected_furniture(furniture_root)
						_selected_furniture_touch_index = event.index
						_selected_furniture_interaction = "move"
						_selected_furniture_drag_active = false
		else:
			var had_pinch_contacts := _touch_points.size() >= 2
			var moved := float(_touch_max_movement.get(event.index, 0.0))
			_touch_points.erase(event.index)
			_touch_start_points.erase(event.index)
			_touch_max_movement.erase(event.index)
			if had_pinch_contacts or _pinch_active or _suppress_single_touch_until_release:
				if _touch_points.size() < 2:
					_finish_pinch_gesture()
					if _touch_points.is_empty():
						_suppress_single_touch_until_release = false
				_placement_touch_index = -1
				_placement_drag_active = false
				_selected_furniture_touch_index = -1
				_selected_furniture_interaction = ""
				_selected_furniture_drag_active = false
				_pan_touch_index = -1
				_pan_touch_active = false
				return
			if _is_placement_active():
				if event.index == _placement_touch_index:
					if moved > TAP_DISTANCE_THRESHOLD or _placement_drag_active:
						_update_furniture_preview(event.position)
						_commit_furniture_placement(event.position)
					else:
						_update_furniture_preview(event.position)
				_placement_touch_index = -1
				_placement_drag_active = false
			elif event.index == _selected_furniture_touch_index and not _selected_furniture_interaction.is_empty():
				if _selected_furniture_interaction == "delete" and moved <= TAP_DISTANCE_THRESHOLD:
					_delete_selected_furniture()
				elif _selected_furniture_interaction == "rotate" and moved <= TAP_DISTANCE_THRESHOLD:
					_rotate_selected_furniture()
				elif _selected_furniture_interaction == "resize":
					if _selected_furniture_drag_active or moved > TAP_DISTANCE_THRESHOLD:
						_commit_selected_furniture_resize(event.position)
					else:
						_step_selected_furniture_scale()
				elif _selected_furniture_interaction == "move":
					if _selected_furniture_drag_active or moved > TAP_DISTANCE_THRESHOLD:
						_commit_selected_furniture_drag(event.position)
					elif is_instance_valid(_selected_furniture_root):
						_apply_furniture_visual_state(_selected_furniture_root, "selected")
				_selected_furniture_touch_index = -1
				_selected_furniture_interaction = ""
				_selected_furniture_drag_active = false
			elif event.index == _pan_touch_index and (_pan_touch_active or moved > PAN_START_DISTANCE_THRESHOLD):
				_pan_touch_index = -1
				_pan_touch_active = false
			elif moved <= TAP_DISTANCE_THRESHOLD:
				_handle_room_tap(event.position)
			_pan_touch_index = -1
			_pan_touch_active = false
	elif event is InputEventScreenDrag:
		var previous_position: Vector2 = event.position - event.relative
		if _touch_points.has(event.index):
			previous_position = _touch_points[event.index] as Vector2
		_touch_points[event.index] = event.position
		if _touch_start_points.has(event.index):
			var start := _touch_start_points[event.index] as Vector2
			_touch_max_movement[event.index] = max(
				float(_touch_max_movement.get(event.index, 0.0)),
				start.distance_to(event.position)
			)
		if _edit_mode:
			return
		if _touch_points.size() >= 2:
			if not _pinch_active:
				_begin_pinch_gesture()
			var pinch_distance := _current_pinch_distance()
			if _pinch_distance > 0.0 and pinch_distance > 0.0:
				_apply_zoom_scale(_pinch_start_zoom_scale * (_pinch_distance / pinch_distance), true)
			var pinch_angle := _current_pinch_angle()
			var angle_delta := wrapf(pinch_angle - _pinch_angle, -PI, PI)
			_pinch_angle = pinch_angle
			if is_instance_valid(_home_pivot) and absf(angle_delta) > 0.0:
				_home_pivot.rotation_degrees.y -= rad_to_deg(angle_delta)
				_angle_index = posmod(int(round((_home_pivot.rotation_degrees.y - BASE_PLAN_ROTATION_Y) / ROTATE_SNAP_STEP_DEG)), 8)
				_update_camera_for_viewport()
			_placement_touch_index = -1
			_selected_furniture_touch_index = -1
			_selected_furniture_interaction = ""
			_selected_furniture_drag_active = false
			_pan_touch_index = -1
			_pan_touch_active = false
			return
		if _suppress_single_touch_until_release:
			return
		if _is_placement_active():
			if event.index == _placement_touch_index:
				_placement_drag_active = true
			_update_furniture_preview(event.position)
			return
		if event.index == _selected_furniture_touch_index and _selected_furniture_interaction == "resize":
			_selected_furniture_drag_active = true
			_update_selected_furniture_resize(event.position)
			return
		if event.index == _selected_furniture_touch_index and _selected_furniture_interaction == "move":
			_selected_furniture_drag_active = true
			_update_selected_furniture_drag(event.position)
			return
		if not _single_finger_pan_allowed():
			return
		if float(_touch_max_movement.get(event.index, 0.0)) <= PAN_START_DISTANCE_THRESHOLD:
			return
		_pan_touch_index = event.index
		_pan_touch_active = true
		_pan_floor_plan(previous_position, event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if OS.has_feature("mobile"):
			return
		if _edit_mode:
			return
		if _suppress_single_touch_until_release:
			return
		if _is_placement_active():
			if _placement_mouse_pressed:
				_placement_mouse_drag_distance = max(
					_placement_mouse_drag_distance,
					_placement_mouse_press_position.distance_to(event.position)
				)
				if _placement_mouse_drag_distance > TAP_DISTANCE_THRESHOLD:
					_placement_drag_active = true
			_update_furniture_preview(event.position)
		elif _selected_furniture_mouse_pressed and _selected_furniture_interaction == "resize":
			_selected_furniture_drag_active = true
			_update_selected_furniture_resize(event.position)
		elif _selected_furniture_mouse_pressed and _selected_furniture_interaction == "move":
			_selected_furniture_drag_active = true
			_update_selected_furniture_drag(event.position)
		else:
			if not _single_finger_pan_allowed():
				return
			_pan_floor_plan(event.position - event.relative, event.position)
	elif event is InputEventMouseButton:
		if OS.has_feature("mobile"):
			return
		if _edit_mode and (
			event.button_index == MOUSE_BUTTON_WHEEL_UP
			or event.button_index == MOUSE_BUTTON_WHEEL_DOWN
		):
			return
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom_scale(_zoom_rest_scale * 0.9)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom_scale(_zoom_rest_scale * 1.1)
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _is_placement_active():
			_placement_mouse_pressed = true
			_placement_mouse_press_position = event.position
			_placement_mouse_drag_distance = 0.0
			_placement_drag_active = false
			_update_furniture_preview(event.position)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _is_placement_active():
			if _placement_mouse_pressed:
				if _placement_drag_active or _placement_mouse_drag_distance > TAP_DISTANCE_THRESHOLD:
					_commit_furniture_placement(event.position)
				else:
					_update_furniture_preview(event.position)
			else:
				_update_furniture_preview(event.position)
			_placement_mouse_pressed = false
			_placement_mouse_drag_distance = 0.0
			_placement_drag_active = false
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _is_furniture_edit_active():
			var screen_position: Vector2 = event.position
			var floor_point := _screen_to_floor(event.position)
			if _selected_furniture_delete_handle_contains(screen_position):
				_selected_furniture_mouse_pressed = true
				_selected_furniture_interaction = "delete"
				_selected_furniture_drag_active = false
			elif _selected_furniture_resize_handle_contains(screen_position):
				if floor_point == Vector2.INF:
					return
				_selected_furniture_mouse_pressed = true
				_selected_furniture_interaction = "resize"
				_selected_furniture_drag_active = false
				_selected_furniture_resize_start_scale_factor = _current_furniture_scale_factor(_selected_furniture_root)
				_selected_furniture_resize_start_distance = maxf(
					floor_point.distance_to(_furniture_center_2d(_selected_furniture_root)),
					0.001
				)
			elif _selected_furniture_handle_contains(screen_position):
				_selected_furniture_mouse_pressed = true
				_selected_furniture_interaction = "rotate"
			else:
				if floor_point != Vector2.INF:
					var furniture_root := _find_furniture_root_at_point(floor_point)
					if is_instance_valid(furniture_root):
						_set_selected_furniture(furniture_root)
						_selected_furniture_mouse_pressed = true
						_selected_furniture_interaction = "move"
						_selected_furniture_drag_active = false
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _selected_furniture_mouse_pressed:
			if _selected_furniture_interaction == "delete":
				_delete_selected_furniture()
			elif _selected_furniture_interaction == "rotate":
				_rotate_selected_furniture()
			elif _selected_furniture_interaction == "resize":
				if _selected_furniture_drag_active:
					_commit_selected_furniture_resize(event.position)
				else:
					_step_selected_furniture_scale()
			elif _selected_furniture_interaction == "move":
				if _selected_furniture_drag_active:
					_commit_selected_furniture_drag(event.position)
				elif is_instance_valid(_selected_furniture_root):
					_apply_furniture_visual_state(_selected_furniture_root, "selected")
			_selected_furniture_mouse_pressed = false
			_selected_furniture_interaction = ""
			_selected_furniture_drag_active = false


func _connect_app_plugin() -> void:
	if _app_plugin_connected:
		return
	if not Engine.has_singleton(APP_PLUGIN_NAME):
		return
	var plugin := Engine.get_singleton(APP_PLUGIN_NAME)
	if plugin == null:
		return
	print("[SmartHome] Android plugin singleton found: %s" % APP_PLUGIN_NAME)
	var had_signal := false
	if plugin.has_signal("view_mode_changed"):
		plugin.connect("view_mode_changed", Callable(self, "_on_view_mode_changed"))
		had_signal = true
	if plugin.has_signal("rotate_requested"):
		plugin.connect("rotate_requested", Callable(self, "_on_rotate_requested"))
		had_signal = true
	if plugin.has_signal("shader_selection_changed"):
		plugin.connect("shader_selection_changed", Callable(self, "_on_shader_selection_changed"))
		had_signal = true
	if plugin.has_signal("furniture_selection_changed"):
		plugin.connect("furniture_selection_changed", Callable(self, "_on_furniture_selection_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_LIGHT_FOCUS_MODE_CHANGED):
		plugin.connect(SIGNAL_LIGHT_FOCUS_MODE_CHANGED, Callable(self, "_on_light_focus_mode_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_TEMPERATURE_FOCUS_MODE_CHANGED):
		plugin.connect(SIGNAL_TEMPERATURE_FOCUS_MODE_CHANGED, Callable(self, "_on_temperature_focus_mode_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_AIR_QUALITY_FOCUS_MODE_CHANGED):
		plugin.connect(SIGNAL_AIR_QUALITY_FOCUS_MODE_CHANGED, Callable(self, "_on_air_quality_focus_mode_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_CAMERA_FOCUS_MODE_CHANGED):
		plugin.connect(SIGNAL_CAMERA_FOCUS_MODE_CHANGED, Callable(self, "_on_camera_focus_mode_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_ENERGY_FOCUS_MODE_CHANGED):
		plugin.connect(SIGNAL_ENERGY_FOCUS_MODE_CHANGED, Callable(self, "_on_energy_focus_mode_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_FLOOR_PLAN_EDIT_MODE_CHANGED):
		plugin.connect(SIGNAL_FLOOR_PLAN_EDIT_MODE_CHANGED, Callable(self, "_on_floor_plan_edit_mode_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_FURNITURE_EDIT_MODE_CHANGED):
		plugin.connect(SIGNAL_FURNITURE_EDIT_MODE_CHANGED, Callable(self, "_on_furniture_edit_mode_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_HOME_SKIN_SELECTED):
		plugin.connect(SIGNAL_HOME_SKIN_SELECTED, Callable(self, "_on_home_skin_selected_signal"))
		had_signal = true
	if plugin.has_signal(SIGNAL_ROOM_FINISH_PREVIEW_REQUESTED):
		plugin.connect(SIGNAL_ROOM_FINISH_PREVIEW_REQUESTED, Callable(self, "_on_room_finish_preview_signal"))
		had_signal = true
	if plugin.has_signal(SIGNAL_ROOM_FINISH_APPLY_TO_ALL_REQUESTED):
		plugin.connect(SIGNAL_ROOM_FINISH_APPLY_TO_ALL_REQUESTED, Callable(self, "_on_apply_room_finish_to_all_signal"))
		had_signal = true
	if plugin.has_signal(SIGNAL_ROOM_FINISH_APPLY_REQUESTED):
		plugin.connect(SIGNAL_ROOM_FINISH_APPLY_REQUESTED, Callable(self, "_on_room_finish_apply_signal"))
		had_signal = true
	if plugin.has_signal(SIGNAL_ROOM_FINISH_CANCEL_REQUESTED):
		plugin.connect(SIGNAL_ROOM_FINISH_CANCEL_REQUESTED, Callable(self, "_on_room_finish_cancel_signal"))
		had_signal = true
	if plugin.has_signal(SIGNAL_FLOOR_PLAN_SESSION_APPLY_REQUESTED):
		plugin.connect(SIGNAL_FLOOR_PLAN_SESSION_APPLY_REQUESTED, Callable(self, "_on_floor_plan_session_apply_signal"))
		had_signal = true
	if plugin.has_signal(SIGNAL_FLOOR_PLAN_SESSION_CANCEL_REQUESTED):
		plugin.connect(SIGNAL_FLOOR_PLAN_SESSION_CANCEL_REQUESTED, Callable(self, "_on_floor_plan_session_cancel_signal"))
		had_signal = true
	if plugin.has_signal(SIGNAL_DEVICE_COMMAND_REQUESTED):
		plugin.connect(SIGNAL_DEVICE_COMMAND_REQUESTED, Callable(self, "_on_device_command_requested"))
		had_signal = true
	if plugin.has_signal(SIGNAL_ACCESSIBILITY_FOCUS_CHANGED):
		plugin.connect(SIGNAL_ACCESSIBILITY_FOCUS_CHANGED, Callable(self, "_on_accessibility_focus_changed"))
		had_signal = true
	if plugin.has_signal(SIGNAL_ACCESSIBILITY_ACTIVATE):
		plugin.connect(SIGNAL_ACCESSIBILITY_ACTIVATE, Callable(self, "_on_accessibility_activate"))
		had_signal = true
	if had_signal:
		_app_plugin_connected = true
	# First publish runs after the floor is built (kicked off from _ready) —
	# trigger one now in case the plugin connected late.
	_publish_accessibility_tree_debounced()


func _on_shader_selection_changed(payload: String) -> void:
	var id := payload.strip_edges()
	if id == "unlit_pack":
		_apply_unlit_shader_pack(true)
	elif id == "unlit_pack_off" or id == "default":
		_apply_unlit_shader_pack(false)


func _apply_unlit_shader_pack(enabled: bool) -> void:
	print("[SmartHome] _apply_unlit_shader_pack -> %s" % enabled)
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
				var mesh_path := String(mesh_path_key)
				var mesh_node := root.get_node_or_null(mesh_path)
				if mesh_node is MeshInstance3D:
					(mesh_node as MeshInstance3D).material_override = cached[mesh_path_key]
		return

	var floor_color_default := Color(0.90, 0.88, 0.84, 1.0)
	var floor_accent := Color(0.82, 0.80, 0.76, 1.0)
	for floor_node in _floor_nodes:
		if not is_instance_valid(floor_node):
			continue
		var finish := floor_node.material_override as BaseMaterial3D
		var base_color: Color = floor_color_default
		if finish != null and finish is StandardMaterial3D:
			base_color = (finish as StandardMaterial3D).albedo_color
			base_color.a = 1.0
		var accent := base_color.darkened(0.08)
		accent.a = 1.0
		var mat := ShaderMaterial.new()
		mat.shader = SHADER_FLOOR_MATERIAL_UNLIT
		mat.set_shader_parameter("base_color", base_color)
		mat.set_shader_parameter("accent_color", Color(base_color.r * 0.92, base_color.g * 0.92, base_color.b * 0.92, 1.0))
		mat.set_shader_parameter("pattern_mode", 1)
		mat.set_shader_parameter("pattern_strength", 0.18)
		mat.set_shader_parameter("uv_tiling", Vector2(6.0, 6.0))
		mat.set_shader_parameter("edge_vignette", 0.12)
		mat.set_shader_parameter("grain_strength", 0.02)
		mat.set_shader_parameter("grain_scale", 64.0)
		mat.set_shader_parameter("alpha", 1.0)
		floor_node.material_override = mat

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

	for root in _furniture_roots:
		if not is_instance_valid(root):
			continue
		if not root.has_meta("furniture_lit_materials"):
			root.set_meta("furniture_lit_materials", {})
		var cache := root.get_meta("furniture_lit_materials", {}) as Dictionary
		var room_color := root.get_meta("furniture_room_color", Color(0.84, 0.86, 0.92)) as Color
		var top_color := room_color.lightened(0.22)
		top_color.a = 1.0
		var side_color := room_color.darkened(0.18)
		side_color.a = 1.0
		var accent_color := room_color.darkened(0.4)
		accent_color.a = 1.0
		var body_overlay: Node = root.get_meta("furniture_body_overlay", null) as Node
		for child in _collect_mesh_instances(root):
			if child == body_overlay:
				continue
			if not cache.has(root.get_path_to(child)):
				cache[root.get_path_to(child)] = child.material_override
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


func _on_furniture_selection_changed(model_id: String) -> void:
	_set_furniture_selection(model_id)


func _on_light_focus_mode_changed(is_active: bool) -> void:
	print("[SmartHome] on_light_focus_mode_changed -> %s" % is_active)
	_light_focus_active = is_active
	if is_active:
		_temperature_focus_active = false
		_air_quality_focus_active = false
		_set_camera_focus_active(false)
		_set_energy_focus_active(false)
	_set_selected_air_quality_device("")
	_apply_light_focus_state()


func _on_temperature_focus_mode_changed(is_active: bool) -> void:
	print("[SmartHome] on_temperature_focus_mode_changed -> %s" % is_active)
	_temperature_focus_active = is_active
	if is_active:
		_light_focus_active = false
		_air_quality_focus_active = false
		_set_camera_focus_active(false)
		_set_energy_focus_active(false)
	_set_selected_air_quality_device("")
	_apply_light_focus_state()


func _on_air_quality_focus_mode_changed(is_active: bool) -> void:
	print("[SmartHome] on_air_quality_focus_mode_changed -> %s" % is_active)
	_air_quality_focus_active = is_active
	if is_active:
		_light_focus_active = false
		_temperature_focus_active = false
		_set_camera_focus_active(false)
		_set_energy_focus_active(false)
	_set_selected_air_quality_device("")
	_apply_light_focus_state()
	# Refresh every air-purifier pin so callouts toggle on/off together with focus.
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if String(device.get("kind", "")) == DEVICE_KIND_AIR_PURIFIER:
			_update_device_pin_visual(device_id)


func _on_camera_focus_mode_changed(is_active: bool) -> void:
	print("[SmartHome] on_camera_focus_mode_changed -> %s" % is_active)
	if is_active:
		_light_focus_active = false
		_temperature_focus_active = false
		_air_quality_focus_active = false
		_set_energy_focus_active(false)
		_set_selected_air_quality_device("")
	_set_camera_focus_active(is_active)
	_apply_light_focus_state()


func _on_energy_focus_mode_changed(is_active: bool) -> void:
	print("[SmartHome] on_energy_focus_mode_changed -> %s" % is_active)
	if is_active:
		_light_focus_active = false
		_temperature_focus_active = false
		_air_quality_focus_active = false
		_set_camera_focus_active(false)
		_set_selected_air_quality_device("")
	_set_energy_focus_active(is_active)
	_apply_light_focus_state()


func _on_floor_plan_edit_mode_changed(is_active: bool) -> void:
	_set_edit_mode(is_active)


func _on_furniture_edit_mode_changed(is_active: bool) -> void:
	_set_furniture_edit_mode(is_active)


func _on_home_skin_selected_signal(skin_id: String) -> void:
	_preview_home_skin(skin_id)


func _on_room_finish_preview_signal(finish_id: String) -> void:
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		return
	_preview_room_finish(room_entry, finish_id)


func _on_apply_room_finish_to_all_signal(finish_id: String) -> void:
	_apply_pending_finish_to_all_rooms(finish_id)


func _on_room_finish_apply_signal() -> void:
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		return
	_commit_room_finish(room_entry)


func _on_room_finish_cancel_signal() -> void:
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		return
	_cancel_room_finish(room_entry)


func _on_floor_plan_session_apply_signal() -> void:
	_commit_all_pending_room_finishes()


func _on_floor_plan_session_cancel_signal() -> void:
	_cancel_all_pending_room_finishes()


func _on_device_command_requested(device_id: String, is_on: bool) -> void:
	print("[SmartHome] on_device_command_requested id=%s is_on=%s" % [device_id, is_on])
	_request_device_state_change(device_id, is_on)


func _log_device_pin_screen_positions() -> void:
	if not is_instance_valid(_camera):
		return
	var lines: Array[String] = []
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if device.is_empty():
			continue
		var pin: Variant = _device_pin_instance(device)
		if pin == null or not pin.has_method("get_screen_anchor_position"):
			continue
		var anchor_variant: Variant = pin.call("get_screen_anchor_position")
		if not (anchor_variant is Vector3):
			continue
		var anchor_position := anchor_variant as Vector3
		var screen_position := _camera.unproject_position(anchor_position)
		lines.append("%s=%s" % [device_id, screen_position.round()])
	if not lines.is_empty():
		print("[SmartHome] device_pin_screen_positions: " + ", ".join(lines))


func _on_view_mode_changed(is_3d: bool) -> void:
	_is_3d_view = is_3d
	_set_zoom_scale_immediate(_zoom_rest_scale)
	_update_camera_for_viewport()


func _on_rotate_requested() -> void:
	if _is_placement_active():
		_placement_preview_rotation_y = wrapf(_placement_preview_rotation_y + 90.0, 0.0, 360.0)
		if _placement_last_screen_position != Vector2.INF:
			_update_furniture_preview(_placement_last_screen_position)
		elif is_instance_valid(_placement_preview_root):
			_placement_preview_root.rotation_degrees.y = _placement_preview_rotation_y
	elif _is_furniture_edit_active() and is_instance_valid(_selected_furniture_root):
		_rotate_selected_furniture()
	else:
		_rotate_to_quadrant(1)


func _build_scene() -> void:
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color.BLACK
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.92, 0.93, 0.96)
	environment.environment.ambient_light_energy = 0.55
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.environment.tonemap_exposure = 1.08
	environment.environment.tonemap_white = 1.6
	add_child(environment)
	_world_environment = environment

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-62.0, -22.0, 0.0)
	key_light.light_energy = 0.36
	key_light.light_color = Color(1.0, 0.97, 0.93)
	key_light.shadow_enabled = true
	key_light.shadow_blur = 7.5
	key_light.shadow_opacity = 0.2
	add_child(key_light)

	var fill_light := OmniLight3D.new()
	fill_light.position = Vector3(-1.0, 2.4, 1.2)
	fill_light.omni_range = 12.0
	fill_light.light_energy = 0.18
	fill_light.light_color = Color(0.88, 0.93, 1.0)
	add_child(fill_light)

	var rim_light := OmniLight3D.new()
	rim_light.position = Vector3(2.6, 1.8, -1.8)
	rim_light.omni_range = 10.0
	rim_light.light_energy = 0.08
	rim_light.light_color = Color(1.0, 0.98, 0.94)
	add_child(rim_light)

	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.fov = _base_camera_fov
	_camera.near = 0.05
	_camera.far = 60.0
	add_child(_camera)
	_camera.make_current()

	_home_pivot = Node3D.new()
	add_child(_home_pivot)


func _build_floor_plan() -> void:
	var plan := _load_floor_plan()
	var floor := _primary_floor(plan)
	if floor.is_empty():
		push_warning("Floor plan missing from %s." % FLOOR_PLAN_PATH)
		return
	# Cache the floor name so the accessibility tree builder can label the
	# floor:* node correctly (e.g. "First floor").
	_a11y_floor_name = String(floor.get("name", "1F"))

	var saved_finish_state := _load_floor_finish_state()
	var saved_home_skin_id := String(saved_finish_state.get("home_skin_id", _active_home_skin_id))
	if HOME_SKINS.has(saved_home_skin_id):
		_active_home_skin_id = saved_home_skin_id
	_pending_home_skin_id = _active_home_skin_id

	_plan_bounds = _compute_floor_bounds(floor)
	_plan_center_raw = _plan_bounds.position + (_plan_bounds.size * 0.5)
	_plan_size = _plan_bounds.size * FLOOR_PLAN_SCALE
	_plan_focus = Vector3(0.0, PLAN_FOCUS_HEIGHT, 0.1)

	_add_foundation()
	_room_entries = _build_room_entries(floor)
	_rooms_by_id.clear()

	for room_index in range(_room_entries.size()):
		var room_entry := _room_entries[room_index]
		var initial_finish_id := _default_finish_for_room(room_entry)
		room_entry["finish_id"] = initial_finish_id
		room_entry["pending_finish_id"] = initial_finish_id
		room_entry["home_default_finish_id"] = initial_finish_id
		room_entry["is_selected"] = false
		_add_room_floor(room_entry)
		_add_room_label(room_entry)
		_rooms_by_id[String(room_entry.get("id", ""))] = room_entry
		_room_entries[room_index] = room_entry

	_restore_saved_room_finishes(saved_finish_state)

	_door_segments.clear()
	for op_raw in floor.get("openings", []):
		if not op_raw is Dictionary:
			continue
		var op := op_raw as Dictionary
		var op_props := op.get("properties", {}) as Dictionary
		if String(op_props.get("category", "")) != "DOOR":
			continue
		var op_coords: Array = op.get("coordinates", [])
		if op_coords.size() < 2:
			continue
		_door_segments.append({
			"from": _scaled_point(op_coords[0]),
			"to": _scaled_point(op_coords[1]),
		})

	var wall_counts := _collect_wall_counts(floor)
	var wall_room_ids := _collect_wall_room_ids(floor)
	var seen_walls := {}
	_wall_tint_entries.clear()
	for room in floor.get("rooms", []):
		if not room is Dictionary:
			continue
		if not _is_visible((room as Dictionary).get("properties", {})):
			continue
		for wall in (room as Dictionary).get("walls", []):
			if wall is Dictionary:
				_add_wall_from_data(wall as Dictionary, wall_counts, wall_room_ids, seen_walls)

	for opening in floor.get("openings", []):
		if opening is Dictionary and _is_visible((opening as Dictionary).get("properties", {})):
			_add_opening_marker(opening as Dictionary)

	_populate_objects(floor)
	# Floor plan is fully built (rooms + walls + pins). Publish the first
	# accessibility tree so TalkBack has something to traverse.
	_publish_accessibility_tree_debounced()
	_home_pivot.rotation_degrees.y = BASE_PLAN_ROTATION_Y
	if SHADER_PREVIEW_UNLIT_PACK_ENABLED:
		_apply_unlit_shader_pack(true)


func _add_foundation() -> void:
	var shadow := MeshInstance3D.new()
	var shadow_mesh := PlaneMesh.new()
	shadow_mesh.size = _plan_size + Vector2.ONE * (PLATFORM_MARGIN * 3.3)
	shadow.mesh = shadow_mesh
	shadow.position = Vector3(0.0, SHADOW_PLANE_Y, 0.05)
	var shadow_material := StandardMaterial3D.new()
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_material.albedo_color = Color(0.0, 0.0, 0.0, 0.06)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow.material_override = shadow_material
	_home_pivot.add_child(shadow)

	var platform := MeshInstance3D.new()
	var platform_mesh := BoxMesh.new()
	platform_mesh.size = Vector3(
		_plan_size.x + PLATFORM_MARGIN * 2.0,
		PLATFORM_HEIGHT,
		_plan_size.y + PLATFORM_MARGIN * 2.0
	)
	platform.mesh = platform_mesh
	platform.position = Vector3(0.0, -PLATFORM_HEIGHT * 0.5, 0.0)
	var platform_material := StandardMaterial3D.new()
	platform_material.albedo_color = Color(0.935, 0.935, 0.94)
	platform_material.roughness = 0.98
	platform.material_override = platform_material
	_home_pivot.add_child(platform)
	_floor_nodes.append(platform)
	_register_focus_mesh(platform)

	var deck := MeshInstance3D.new()
	var deck_mesh := PlaneMesh.new()
	deck_mesh.size = _plan_size + Vector2.ONE * 0.08
	deck.mesh = deck_mesh
	deck.position = Vector3(0.0, 0.001, 0.0)
	var deck_material := StandardMaterial3D.new()
	deck_material.albedo_color = Color(0.972, 0.972, 0.975)
	deck_material.roughness = 1.0
	deck.material_override = deck_material
	_home_pivot.add_child(deck)
	_floor_nodes.append(deck)
	_register_focus_mesh(deck)


func _build_room_entries(floor: Dictionary) -> Array[Dictionary]:
	var raw_entries: Array[Dictionary] = []
	for room in floor.get("rooms", []):
		if not room is Dictionary:
			continue
		var room_dict := room as Dictionary
		if not _is_visible(room_dict.get("properties", {})):
			continue
		var plane := room_dict.get("plane", {}) as Dictionary
		var polygon := _scaled_polygon(plane.get("coordinates", []))
		if polygon.size() < 3:
			continue
		raw_entries.append({
			"id": String(room_dict.get("id", "")),
			"category": String((room_dict.get("properties", {}) as Dictionary).get("category", "ROOM")),
			"polygon": polygon,
			"centroid": _polygon_centroid(polygon),
			"bounds": _bounds_for_polygon(polygon),
			"area": abs(_polygon_area(polygon)),
			"source_color": _room_color(room_dict.get("properties", {}) as Dictionary),
		})

	var entries := raw_entries.duplicate(true) as Array[Dictionary]
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("area", 0.0)) > float(b.get("area", 0.0))
	)
	var largest_room_id := String(entries[0].get("id", "")) if not entries.is_empty() else ""
	var groups := {}
	for entry in entries:
		var category := String(entry.get("category", "ROOM"))
		if not groups.has(category):
			groups[category] = []
		groups[category].append(String(entry.get("id", "")))

	var category_ranks := {}
	for category in groups.keys():
		var ids: Array = groups[category]
		category_ranks[category] = {}
		for index in range(ids.size()):
			category_ranks[category][String(ids[index])] = index

	var final_entries: Array[Dictionary] = []
	for entry in raw_entries:
		var category := String(entry.get("category", "ROOM"))
		var room_id := String(entry.get("id", ""))
		var category_total := int((groups.get(category, []) as Array).size())
		var category_rank := int((category_ranks.get(category, {}) as Dictionary).get(room_id, 0))
		var label := _smartthings_room_label(category, category_rank, category_total, room_id == largest_room_id)
		entry["label"] = label
		entry["display_color"] = _smartthings_room_color(label, category, entry.get("source_color", Color(0.9, 0.9, 0.9)))
		final_entries.append(entry)
	return final_entries


func _collect_wall_counts(floor: Dictionary) -> Dictionary:
	var counts := {}
	for room in floor.get("rooms", []):
		if not room is Dictionary:
			continue
		for wall in (room as Dictionary).get("walls", []):
			if not wall is Dictionary:
				continue
			var coordinates: Array = (wall as Dictionary).get("coordinates", [])
			if not coordinates is Array or coordinates.size() < 2:
				continue
			var from := _scaled_point(coordinates[0])
			var to := _scaled_point(coordinates[1])
			var key := _segment_key(from, to)
			counts[key] = int(counts.get(key, 0)) + 1
	return counts


func _collect_wall_room_ids(floor: Dictionary) -> Dictionary:
	var mapping := {}
	for room in floor.get("rooms", []):
		if not room is Dictionary:
			continue
		var room_dict := room as Dictionary
		if not _is_visible(room_dict.get("properties", {})):
			continue
		var room_id := String(room_dict.get("id", ""))
		if room_id.is_empty():
			continue
		for wall in room_dict.get("walls", []):
			if not wall is Dictionary:
				continue
			var coordinates: Array = (wall as Dictionary).get("coordinates", [])
			if not coordinates is Array or coordinates.size() < 2:
				continue
			var from := _scaled_point(coordinates[0])
			var to := _scaled_point(coordinates[1])
			var key := _segment_key(from, to)
			var ids: Array = mapping.get(key, []) as Array
			if not ids.has(room_id):
				ids.append(room_id)
			mapping[key] = ids
	return mapping


func _add_room_floor(room_entry: Dictionary) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = _build_polygon_mesh(room_entry.get("polygon", PackedVector2Array()))
	instance.position.y = FLOOR_SURFACE_Y
	room_entry["floor_node"] = instance
	_render_room_finish(room_entry, String(room_entry.get("finish_id", "oak_light")))
	_home_pivot.add_child(instance)
	_floor_nodes.append(instance)
	_register_focus_mesh(instance)


func _add_room_label(room_entry: Dictionary) -> void:
	var centroid := room_entry.get("centroid", Vector2.ZERO) as Vector2
	var room_color := room_entry.get("display_color", Color(0.9, 0.9, 0.9)) as Color
	var label_text := String(room_entry.get("label", "Room"))
	var label_root := _build_floor_label_decal(label_text, room_color)
	label_root.position = Vector3(centroid.x, LABEL_SURFACE_Y, centroid.y)
	_home_pivot.add_child(label_root)
	_label_nodes.append(label_root)
	_register_focus_mesh_tree(label_root)


func _add_wall_from_data(wall: Dictionary, wall_counts: Dictionary, wall_room_ids: Dictionary, seen_walls: Dictionary) -> void:
	var coordinates: Array = wall.get("coordinates", [])
	if not coordinates is Array or coordinates.size() < 2:
		return

	var from := _scaled_point(coordinates[0])
	var to := _scaled_point(coordinates[1])
	var key := _segment_key(from, to)
	if seen_walls.has(key):
		return
	seen_walls[key] = true

	var delta := to - from
	var length := delta.length()
	if length <= 0.001:
		return

	var is_exterior := int(wall_counts.get(key, 1)) == 1
	var wall_height: float = EXTERIOR_WALL_HEIGHT if is_exterior else INTERIOR_WALL_HEIGHT
	var room_ids: Array = wall_room_ids.get(key, []) as Array

	var gaps := _door_gaps_for_wall(from, to, length)
	var t_cursor := 0.0
	for gap in gaps:
		var gap_start := float(gap.x)
		var gap_end := float(gap.y)
		if gap_start > t_cursor:
			_emit_wall_segment(from, to, t_cursor, gap_start, wall_height, is_exterior, room_ids)
		t_cursor = maxf(t_cursor, gap_end)
	if t_cursor < 1.0:
		_emit_wall_segment(from, to, t_cursor, 1.0, wall_height, is_exterior, room_ids)


func _emit_wall_segment(from: Vector2, to: Vector2, t0: float, t1: float, wall_height: float, is_exterior: bool, room_ids: Array = []) -> void:
	if t1 - t0 < 0.002:
		return
	var sub_from := from.lerp(to, t0)
	var sub_to := from.lerp(to, t1)
	var delta := sub_to - sub_from
	var length := delta.length()
	if length <= 0.001:
		return
	var wall_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(WALL_THICKNESS, wall_height, length)
	wall_instance.mesh = mesh
	wall_instance.position = Vector3((sub_from.x + sub_to.x) * 0.5, wall_height * 0.5, (sub_from.y + sub_to.y) * 0.5)
	wall_instance.look_at_from_position(
		wall_instance.position,
		wall_instance.position + Vector3(delta.x, 0.0, delta.y),
		Vector3.UP,
		true
	)
	var tint := _wall_tint_for_room_ids(room_ids, is_exterior)
	var mat_solid := _make_wall_material(is_exterior, tint)
	wall_instance.material_override = mat_solid
	_home_pivot.add_child(wall_instance)
	_wall_nodes.append(wall_instance)
	_wall_tint_entries.append({
		"mesh": wall_instance,
		"is_exterior": is_exterior,
		"room_ids": room_ids.duplicate(),
	})
	_register_focus_mesh(wall_instance)
	if is_exterior:
		var midpoint := (sub_from + sub_to) * 0.5
		var perp := Vector2(-delta.y, delta.x)
		if perp.length() > 0.0001:
			perp = perp.normalized()
			if perp.dot(midpoint) < 0.0:
				perp = -perp
		var mat_dither := _make_wall_material_dither(is_exterior, tint)
		_exterior_wall_records.append({
			"mesh": wall_instance,
			"box": mesh,
			"outward": perp,
			"length": length,
			"base_height": wall_height,
			"midpoint": midpoint,
			"mat_solid": mat_solid,
			"mat_dither": mat_dither,
		})


func _door_gaps_for_wall(from: Vector2, to: Vector2, length: float) -> Array:
	var gaps: Array = []
	if _door_segments.is_empty() or length <= 0.001:
		return gaps
	var dir := to - from
	var len_sq := dir.length_squared()
	var axis := dir / length
	var perp := Vector2(-axis.y, axis.x)
	var collinear_eps := 0.012
	for door in _door_segments:
		var d_from: Vector2 = door.get("from", Vector2.ZERO)
		var d_to: Vector2 = door.get("to", Vector2.ZERO)
		if absf((d_from - from).dot(perp)) > collinear_eps:
			continue
		if absf((d_to - from).dot(perp)) > collinear_eps:
			continue
		var t1 := (d_from - from).dot(dir) / len_sq
		var t2 := (d_to - from).dot(dir) / len_sq
		var t_start := clampf(minf(t1, t2), 0.0, 1.0)
		var t_end := clampf(maxf(t1, t2), 0.0, 1.0)
		if t_end - t_start < 0.005:
			continue
		gaps.append(Vector2(t_start, t_end))
	gaps.sort_custom(func(a, b): return a.x < b.x)
	var merged: Array = []
	for iv in gaps:
		if merged.is_empty() or iv.x > float(merged[-1].y):
			merged.append(iv)
		else:
			merged[-1] = Vector2(merged[-1].x, maxf(merged[-1].y, iv.y))
	return merged


func _add_opening_marker(opening: Dictionary) -> void:
	var coordinates: Array = opening.get("coordinates", [])
	if not coordinates is Array or coordinates.size() < 2:
		return

	var from := _scaled_point(coordinates[0])
	var to := _scaled_point(coordinates[1])
	var delta := to - from
	var length := delta.length()
	if length <= 0.001:
		return

	var category := String((opening.get("properties", {}) as Dictionary).get("category", "OPENING"))
	var marker := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(WALL_THICKNESS * 0.32, MARKER_HEIGHT, length)
	marker.mesh = mesh
	marker.position = Vector3((from.x + to.x) * 0.5, MARKER_HEIGHT * 0.5 + 0.006, (from.y + to.y) * 0.5)
	marker.look_at_from_position(
		marker.position,
		marker.position + Vector3(delta.x, 0.0, delta.y),
		Vector3.UP,
		true
	)
	var material := StandardMaterial3D.new()
	if category == "DOOR":
		material.albedo_color = Color(1.0, 0.93, 0.81, 0.62)
	else:
		material.albedo_color = Color(0.83, 0.95, 1.0, 0.58)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	marker.material_override = material
	_home_pivot.add_child(marker)
	_register_focus_mesh(marker)


func _populate_objects(floor: Dictionary) -> void:
	var placed_per_room := {}
	for object_data in floor.get("objects", []):
		if not object_data is Dictionary:
			continue
		var object_dict := object_data as Dictionary
		if not _is_visible(object_dict.get("properties", {})):
			continue
		var coordinates := object_dict.get("coordinates", {}) as Dictionary
		var position_data: Array = coordinates.get("position", [])
		if not position_data is Array or position_data.size() < 3:
			continue

		var raw_height := float(position_data[1]) * FLOOR_HEIGHT_SCALE
		var position_2d := _scaled_point(position_data)
		var room_entry := _find_room_entry(position_2d)
		if room_entry.is_empty():
			continue

		var properties := object_dict.get("properties", {}) as Dictionary
		if _is_device_object(properties, raw_height):
			continue

		var room_id := String(room_entry.get("id", ""))
		var category := String(room_entry.get("category", "ROOM"))
		var room_limit := int(ROOM_FURNITURE_LIMITS.get(category, 1))
		if int(placed_per_room.get(room_id, 0)) >= room_limit:
			continue

		var model_id := _model_for_category(category)
		var rotation_y := 0.0
		var rotation_data: Array = coordinates.get("rotation", [])
		if rotation_data is Array and rotation_data.size() >= 2:
			rotation_y = float(rotation_data[1])
		var active_finish_id := String(room_entry.get("finish_id", _default_finish_for_room(room_entry)))
		var room_color := _resolve_room_floor_color(room_entry, active_finish_id)
		if is_instance_valid(_add_furniture_instance(model_id, position_2d, rotation_y, room_color, room_id)):
			placed_per_room[room_id] = int(placed_per_room.get(room_id, 0)) + 1

	_populate_sample_devices()
	_populate_sample_air_purifiers()


func _add_furniture_instance(
	model_id: String,
	position_2d: Vector2,
	rotation_y: float,
	room_color: Color,
	room_id: String = "",
) -> Node3D:
	var floor_y := _sample_floor_height(position_2d)
	var root = _create_furniture_root(model_id, position_2d, floor_y, rotation_y, room_color)
	if root == null:
		return null
	root.set_meta("furniture_room_id", room_id)
	_home_pivot.add_child(root)
	_furniture_roots.append(root)
	_register_focus_mesh_tree(root)
	return root


func _create_furniture_root(
	model_id: String,
	position_2d: Vector2,
	floor_y: float,
	rotation_y: float,
	room_color: Color,
	is_preview: bool = false,
):
	var model = _instantiate_furniture_model(model_id)
	if model == null:
		return null

	var root := Node3D.new()
	root.position = Vector3(position_2d.x, floor_y, position_2d.y)
	root.rotation_degrees.y = rotation_y
	root.add_child(model)

	var grounded_aabb := _ground_model_to_floor(model, model_id)
	root.set_meta("furniture_model_id", model_id)
	root.set_meta("furniture_model_node", model)
	root.set_meta("furniture_base_scale", float(_model_scales.get(model_id, 1.0)))
	root.set_meta("furniture_scale_factor", 1.0)
	root.set_meta("furniture_room_color", room_color)
	root.set_meta("furniture_is_preview", is_preview)
	_apply_two_tone_shadow_to_furniture(root, room_color, is_preview)
	root.set_meta("furniture_local_aabb", grounded_aabb)
	root.set_meta("furniture_footprint_local", _footprint_polygon_from_aabb(grounded_aabb))
	root.set_meta(
		"furniture_collision_footprint_local",
		_footprint_polygon_from_aabb(grounded_aabb, FURNITURE_COLLISION_PADDING)
	)
	_refresh_furniture_aux_nodes(root, grounded_aabb)
	_apply_furniture_visual_state(root, "preview" if is_preview else "normal")
	return root


func _refresh_furniture_aux_nodes(root: Node3D, grounded_aabb: AABB) -> void:
	if not is_instance_valid(root):
		return
	var room_color := root.get_meta("furniture_room_color", Color(0.84, 0.86, 0.92)) as Color
	var model_id := String(root.get_meta("furniture_model_id", ""))
	var is_preview := bool(root.get_meta("furniture_is_preview", false))
	var previous_shadow := root.get_meta("furniture_shadow_node", null) as Node3D
	if is_instance_valid(previous_shadow):
		previous_shadow.queue_free()
	var previous_body_overlay := root.get_meta("furniture_body_overlay", null) as MeshInstance3D
	if is_instance_valid(previous_body_overlay):
		previous_body_overlay.queue_free()
	var previous_gizmo := root.get_meta("furniture_selection_gizmo", null) as Node3D
	if is_instance_valid(previous_gizmo):
		previous_gizmo.queue_free()

	var shadow := _build_contact_shadow(grounded_aabb, room_color, model_id, is_preview)
	root.set_meta("furniture_shadow_node", shadow)
	root.add_child(shadow)

	var body_overlay := _build_furniture_body_overlay(grounded_aabb)
	root.set_meta("furniture_body_overlay", body_overlay)
	root.add_child(body_overlay)

	var selection_gizmo := _build_furniture_selection_gizmo(grounded_aabb)
	root.set_meta("furniture_selection_gizmo", selection_gizmo)
	root.set_meta(
		"furniture_rotate_handle_local",
		selection_gizmo.get_meta("rotate_handle_local", Vector3.INF)
	)
	root.set_meta(
		"furniture_resize_handle_local",
		selection_gizmo.get_meta("resize_handle_local", Vector3.INF)
	)
	root.set_meta(
		"furniture_delete_handle_local",
		selection_gizmo.get_meta("delete_handle_local", Vector3.INF)
	)
	root.add_child(selection_gizmo)


func _apply_furniture_scale_factor(root: Node3D, scale_factor: float) -> float:
	if not is_instance_valid(root):
		return 1.0
	var clamped_scale := clampf(
		round(scale_factor / FURNITURE_SCALE_STEP) * FURNITURE_SCALE_STEP,
		FURNITURE_SCALE_MIN,
		FURNITURE_SCALE_MAX
	)
	var current_scale := float(root.get_meta("furniture_scale_factor", 1.0))
	if is_equal_approx(current_scale, clamped_scale):
		return current_scale
	var model_id := String(root.get_meta("furniture_model_id", ""))
	var model := root.get_meta("furniture_model_node", null) as Node3D
	if not is_instance_valid(model):
		return current_scale
	var base_scale := float(root.get_meta("furniture_base_scale", _model_scales.get(model_id, 1.0)))
	model.scale = Vector3.ONE * base_scale * clamped_scale
	var grounded_aabb := _ground_model_to_floor(model, model_id)
	root.set_meta("furniture_scale_factor", clamped_scale)
	root.set_meta("furniture_local_aabb", grounded_aabb)
	root.set_meta("furniture_footprint_local", _footprint_polygon_from_aabb(grounded_aabb))
	root.set_meta(
		"furniture_collision_footprint_local",
		_footprint_polygon_from_aabb(grounded_aabb, FURNITURE_COLLISION_PADDING)
	)
	_refresh_furniture_aux_nodes(root, grounded_aabb)
	var current_state := String(root.get_meta("furniture_visual_state", "normal"))
	root.set_meta("furniture_visual_state", "")
	_apply_furniture_visual_state(root, current_state)
	return clamped_scale


func _build_furniture_selection_gizmo(local_aabb: AABB) -> Node3D:
	var gizmo := Node3D.new()
	gizmo.visible = false

	var selection_padding := _selection_box_padding_for_aabb(local_aabb)
	var outline_thickness := _selection_outline_thickness_for_aabb(local_aabb)
	var min_x := local_aabb.position.x - selection_padding
	var max_x := local_aabb.position.x + local_aabb.size.x + selection_padding
	var min_y := local_aabb.position.y - selection_padding * 0.18
	var max_y := local_aabb.position.y + local_aabb.size.y + selection_padding * 0.7
	var min_z := local_aabb.position.z - selection_padding
	var max_z := local_aabb.position.z + local_aabb.size.z + selection_padding
	var center_x := (min_x + max_x) * 0.5
	var center_y := (min_y + max_y) * 0.5
	var center_z := (min_z + max_z) * 0.5
	var rotate_offset := maxf(FURNITURE_ROTATE_HANDLE_OFFSET * 2.2, (max_z - min_z) * 0.42)

	var corners := {
		"lb0": Vector3(min_x, min_y, min_z),
		"rb0": Vector3(max_x, min_y, min_z),
		"rt0": Vector3(max_x, min_y, max_z),
		"lt0": Vector3(min_x, min_y, max_z),
		"lb1": Vector3(min_x, max_y, min_z),
		"rb1": Vector3(max_x, max_y, min_z),
		"rt1": Vector3(max_x, max_y, max_z),
		"lt1": Vector3(min_x, max_y, max_z),
	}
	var edge_pairs := [
		["lb0", "rb0"],
		["rb0", "rt0"],
		["rt0", "lt0"],
		["lt0", "lb0"],
		["lb1", "rb1"],
		["rb1", "rt1"],
		["rt1", "lt1"],
		["lt1", "lb1"],
		["lb0", "lb1"],
		["rb0", "rb1"],
		["rt0", "rt1"],
		["lt0", "lt1"],
		]
	for pair in edge_pairs:
		gizmo.add_child(
			_make_selection_edge(
				corners[String(pair[0])] as Vector3,
				corners[String(pair[1])] as Vector3,
				outline_thickness
			)
		)

	var rotate_handle_local := Vector3(
		center_x,
		min_y + outline_thickness * 0.6,
		max_z + rotate_offset
	)
	var resize_handle_local := Vector3(
		max_x + FURNITURE_ROTATE_HANDLE_OFFSET * 0.75,
		max_y + FURNITURE_HANDLE_ELEVATION * 0.45,
		max_z + FURNITURE_ROTATE_HANDLE_OFFSET
	)
	var delete_handle_local := Vector3(
		min_x - FURNITURE_ROTATE_HANDLE_OFFSET * 0.85,
		max_y + FURNITURE_HANDLE_ELEVATION,
		min_z - FURNITURE_ROTATE_HANDLE_OFFSET * 0.55
	)
	gizmo.add_child(
		_make_selection_axis_line(
			Vector3(center_x, center_y, center_z),
			rotate_handle_local,
			outline_thickness
		)
	)
	gizmo.add_child(_make_selection_handle(rotate_handle_local, "rotate"))
	gizmo.add_child(_make_selection_handle(resize_handle_local, "resize"))
	gizmo.add_child(_make_selection_handle(delete_handle_local, "delete"))
	gizmo.set_meta("rotate_handle_local", rotate_handle_local)
	gizmo.set_meta("resize_handle_local", resize_handle_local)
	gizmo.set_meta("delete_handle_local", delete_handle_local)
	return gizmo


func _make_selection_edge(
	from_position: Vector3,
	to_position: Vector3,
	thickness: float,
) -> MeshInstance3D:
	return _make_selection_line(
		from_position,
		to_position,
		thickness,
		_selection_gizmo_material(false)
	)


func _make_selection_axis_line(
	from_position: Vector3,
	to_position: Vector3,
	thickness: float,
) -> MeshInstance3D:
	var line := _make_selection_line(
		from_position,
		to_position,
		maxf(thickness * 0.34, 0.006),
		_selection_axis_material(false)
	)
	line.set_meta("selection_axis_line", true)
	return line


func _make_selection_line(
	from_position: Vector3,
	to_position: Vector3,
	thickness: float,
	material: Material,
) -> MeshInstance3D:
	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	var delta := to_position - from_position
	var size := Vector3.ONE * thickness
	if abs(delta.x) >= abs(delta.y) and abs(delta.x) >= abs(delta.z):
		size.x = abs(delta.x) + thickness
	elif abs(delta.y) >= abs(delta.z):
		size.y = abs(delta.y) + thickness
	else:
		size.z = abs(delta.z) + thickness
	mesh.size = size
	edge.mesh = mesh
	edge.position = from_position.lerp(to_position, 0.5)
	edge.material_override = material
	edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return edge


func _selection_gizmo_material(is_invalid: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = FURNITURE_INVALID_COLOR if is_invalid else FURNITURE_SELECTION_COLOR
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy_multiplier = 1.45
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = true
	material.render_priority = 24
	return material


func _selection_axis_material(is_invalid: bool) -> StandardMaterial3D:
	var material := _selection_gizmo_material(is_invalid)
	material.albedo_color = Color(
		material.albedo_color.r,
		material.albedo_color.g,
		material.albedo_color.b,
		0.72
	)
	material.emission = material.albedo_color
	return material


func _make_selection_handle(position: Vector3, kind: String) -> MeshInstance3D:
	var handle := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2.ONE * FURNITURE_HANDLE_PLANE_SIZE
	handle.mesh = mesh
	handle.position = position
	handle.rotation_degrees.x = -90.0
	handle.material_override = _selection_handle_material(kind, false)
	handle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	handle.set_meta("selection_handle_kind", kind)
	return handle


func _selection_handle_material(kind: String, is_invalid: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = _selection_handle_texture(kind, is_invalid)
	material.albedo_color = Color.WHITE
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = true
	material.render_priority = 26
	return material


func _selection_handle_texture(kind: String, is_invalid: bool) -> Texture2D:
	var cache_key := "%s:%s" % [kind, is_invalid]
	if _furniture_handle_texture_cache.has(cache_key):
		return _furniture_handle_texture_cache.get(cache_key) as Texture2D

	var image := Image.create(
		FURNITURE_HANDLE_ICON_SIZE,
		FURNITURE_HANDLE_ICON_SIZE,
		false,
		Image.FORMAT_RGBA8
	)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	var center := Vector2.ONE * (float(FURNITURE_HANDLE_ICON_SIZE) * 0.5)
	var background_color := _selection_handle_background_color(kind, is_invalid)
	_stamp_icon_circle(
		image,
		center,
		float(FURNITURE_HANDLE_ICON_SIZE) * 0.44,
		Color(background_color.r, background_color.g, background_color.b, 0.96)
	)
	if kind == "resize":
		_draw_resize_handle_icon(image, center, Color.WHITE)
	elif kind == "delete":
		_draw_delete_handle_icon(image, center, Color.WHITE)
	else:
		_draw_rotate_handle_icon(image, center, Color.WHITE)

	var texture := ImageTexture.create_from_image(image)
	_furniture_handle_texture_cache[cache_key] = texture
	return texture


func _selection_handle_background_color(kind: String, is_invalid: bool) -> Color:
	if kind == "delete":
		return Color(0.9, 0.25, 0.25, 1.0)
	return FURNITURE_INVALID_COLOR if is_invalid else FURNITURE_SELECTION_COLOR


func _stamp_icon_circle(image: Image, center: Vector2, radius: float, color: Color) -> void:
	var min_x := maxi(0, int(floor(center.x - radius)))
	var max_x := mini(image.get_width() - 1, int(ceil(center.x + radius)))
	var min_y := maxi(0, int(floor(center.y - radius)))
	var max_y := mini(image.get_height() - 1, int(ceil(center.y + radius)))
	var radius_squared := radius * radius
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var delta := Vector2(float(x) + 0.5, float(y) + 0.5) - center
			if delta.length_squared() <= radius_squared:
				image.set_pixel(x, y, color)


func _draw_icon_line(image: Image, from_point: Vector2, to_point: Vector2, color: Color, thickness: float) -> void:
	var steps := maxi(1, int(ceil(from_point.distance_to(to_point) * 1.2)))
	for step in range(steps + 1):
		var point := from_point.lerp(to_point, float(step) / float(steps))
		_stamp_icon_circle(image, point, thickness * 0.5, color)


func _draw_icon_arc(
	image: Image,
	center: Vector2,
	radius: float,
	start_angle: float,
	end_angle: float,
	color: Color,
	thickness: float,
	segments := 48,
) -> void:
	var previous_point := center + Vector2(cos(start_angle), sin(start_angle)) * radius
	for segment in range(1, segments + 1):
		var t := float(segment) / float(segments)
		var angle := lerpf(start_angle, end_angle, t)
		var next_point := center + Vector2(cos(angle), sin(angle)) * radius
		_draw_icon_line(image, previous_point, next_point, color, thickness)
		previous_point = next_point


func _draw_icon_arrow_head(
	image: Image,
	tip: Vector2,
	direction: Vector2,
	color: Color,
	size: float,
	thickness: float,
) -> void:
	if direction.length() <= 0.0001:
		return
	var normalized := direction.normalized()
	var side := Vector2(-normalized.y, normalized.x)
	var base := tip - normalized * size
	_draw_icon_line(image, tip, base + side * size * 0.55, color, thickness)
	_draw_icon_line(image, tip, base - side * size * 0.55, color, thickness)


func _draw_rotate_handle_icon(image: Image, center: Vector2, color: Color) -> void:
	var radius := float(FURNITURE_HANDLE_ICON_SIZE) * 0.18
	var thickness := 8.0
	var start_angle := deg_to_rad(28.0)
	var end_angle := deg_to_rad(318.0)
	_draw_icon_arc(image, center, radius, start_angle, end_angle, color, thickness)
	var tip := center + Vector2(cos(end_angle), sin(end_angle)) * radius
	_draw_icon_arrow_head(
		image,
		tip,
		Vector2(cos(end_angle + 0.35), sin(end_angle + 0.35)),
		color,
		15.0,
		thickness
	)


func _draw_resize_handle_icon(image: Image, center: Vector2, color: Color) -> void:
	var start := center + Vector2(-22.0, 22.0)
	var finish := center + Vector2(22.0, -22.0)
	var thickness := 8.0
	_draw_icon_line(image, start, finish, color, thickness)
	_draw_icon_arrow_head(image, start, start - finish, color, 14.0, thickness)
	_draw_icon_arrow_head(image, finish, finish - start, color, 14.0, thickness)


func _draw_delete_handle_icon(image: Image, center: Vector2, color: Color) -> void:
	var thickness := 7.0
	var lid_left := center + Vector2(-18.0, -15.0)
	var lid_right := center + Vector2(18.0, -15.0)
	var body_top_left := center + Vector2(-14.0, -7.0)
	var body_top_right := center + Vector2(14.0, -7.0)
	var body_bottom_left := center + Vector2(-10.0, 22.0)
	var body_bottom_right := center + Vector2(10.0, 22.0)
	_draw_icon_line(image, lid_left, lid_right, color, thickness)
	_draw_icon_line(image, center + Vector2(-7.0, -21.0), center + Vector2(7.0, -21.0), color, thickness)
	_draw_icon_line(image, body_top_left, body_top_right, color, thickness)
	_draw_icon_line(image, body_top_left, body_bottom_left, color, thickness)
	_draw_icon_line(image, body_top_right, body_bottom_right, color, thickness)
	_draw_icon_line(image, body_bottom_left, body_bottom_right, color, thickness)
	_draw_icon_line(image, center + Vector2(-4.0, -2.0), center + Vector2(-4.0, 16.0), color, thickness * 0.72)
	_draw_icon_line(image, center + Vector2(4.0, -2.0), center + Vector2(4.0, 16.0), color, thickness * 0.72)


func _build_furniture_body_overlay(local_aabb: AABB) -> MeshInstance3D:
	var overlay := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	var overlay_padding := _selection_box_padding_for_aabb(local_aabb) * 0.66
	mesh.size = local_aabb.size + Vector3.ONE * overlay_padding * 1.1
	overlay.mesh = mesh
	overlay.position = local_aabb.get_center()
	overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	overlay.material_override = _furniture_body_overlay_material(FURNITURE_SELECTION_COLOR, 0.0, 0.0)
	overlay.visible = false
	return overlay


func _selection_box_padding_for_aabb(local_aabb: AABB) -> float:
	var smallest_span := minf(local_aabb.size.x, minf(local_aabb.size.y, local_aabb.size.z))
	return clampf(
		smallest_span * FURNITURE_SELECTION_BOX_PADDING_FRACTION,
		FURNITURE_SELECTION_BOX_PADDING_MIN,
		FURNITURE_SELECTION_BOX_PADDING_MAX
	)


func _selection_outline_thickness_for_aabb(local_aabb: AABB) -> float:
	var smallest_span := minf(local_aabb.size.x, minf(local_aabb.size.y, local_aabb.size.z))
	return clampf(
		smallest_span * FURNITURE_SELECTION_OUTLINE_THICKNESS_FRACTION,
		FURNITURE_SELECTION_OUTLINE_THICKNESS_MIN,
		FURNITURE_SELECTION_OUTLINE_THICKNESS_MAX
	)


func _furniture_body_overlay_material(color: Color, alpha_bottom: float, alpha_top: float) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, depth_test_disabled;

uniform vec4 tint_color : source_color = vec4(0.0, 0.37, 0.72, 0.18);
uniform float alpha_bottom = 0.16;
uniform float alpha_top = 0.05;

void fragment() {
	float gradient = clamp(UV.y, 0.0, 1.0);
	ALBEDO = tint_color.rgb;
	ALPHA = mix(alpha_bottom, alpha_top, gradient);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint_color", color)
	material.set_shader_parameter("alpha_bottom", alpha_bottom)
	material.set_shader_parameter("alpha_top", alpha_top)
	return material


func _instantiate_furniture_model(model_id: String, scale_factor := 1.0):
	var asset_path := String(_model_paths.get(model_id, ""))
	if asset_path.is_empty():
		print("[SmartHome] Missing furniture asset path for model_id=%s" % model_id)
		return null
	var packed := load(asset_path) as PackedScene
	if packed == null:
		print("[SmartHome] Failed to load furniture asset: %s (model_id=%s)" % [asset_path, model_id])
		return null
	var instance := packed.instantiate()
	if not instance is Node3D:
		print("[SmartHome] Furniture asset did not instantiate as Node3D: %s (model_id=%s)" % [asset_path, model_id])
		instance.free()
		return null
	var model := instance as Node3D
	model.scale = Vector3.ONE * float(_model_scales.get(model_id, 1.0)) * scale_factor
	return model


func _sample_floor_height(_position_2d: Vector2) -> float:
	return FLOOR_SURFACE_Y


func _ground_model_to_floor(model: Node3D, model_id: String) -> AABB:
	var local_aabb := _collect_node_aabb(model)
	model.position.y = -local_aabb.position.y + FURNITURE_FLOOR_EPSILON + float(_model_floor_offsets.get(model_id, 0.0))
	return _collect_node_aabb(model)


func _model_layout(model_id: String, scale_factor := 1.0) -> Dictionary:
	var cache_key := "%s:%.2f" % [model_id, scale_factor]
	if _model_layout_cache.has(cache_key):
		return _model_layout_cache.get(cache_key, {}) as Dictionary

	var model = _instantiate_furniture_model(model_id, scale_factor)
	if model == null:
		return {}

	var grounded_aabb := _ground_model_to_floor(model, model_id)
	var layout := {
		"local_aabb": grounded_aabb,
		"footprint_local": _footprint_polygon_from_aabb(grounded_aabb),
		"collision_footprint_local": _footprint_polygon_from_aabb(grounded_aabb, FURNITURE_COLLISION_PADDING),
	}
	model.free()
	_model_layout_cache[cache_key] = layout
	return layout


func _footprint_polygon_from_aabb(local_aabb: AABB, padding := 0.0) -> PackedVector2Array:
	return PackedVector2Array(
		[
			Vector2(local_aabb.position.x - padding, local_aabb.position.z - padding),
			Vector2(local_aabb.position.x + local_aabb.size.x + padding, local_aabb.position.z - padding),
			Vector2(local_aabb.position.x + local_aabb.size.x + padding, local_aabb.position.z + local_aabb.size.z + padding),
			Vector2(local_aabb.position.x - padding, local_aabb.position.z + local_aabb.size.z + padding),
		]
	)


func _transform_footprint_polygon(
	local_polygon: PackedVector2Array,
	position_2d: Vector2,
	rotation_y: float,
) -> PackedVector2Array:
	var transformed := PackedVector2Array()
	var rotation_radians := deg_to_rad(rotation_y)
	for local_point in local_polygon:
		var rotated := Vector3(local_point.x, 0.0, local_point.y).rotated(Vector3.UP, rotation_radians)
		transformed.append(position_2d + Vector2(rotated.x, rotated.z))
	return transformed


func _footprint_sample_points(world_polygon: PackedVector2Array) -> Array[Vector2]:
	var samples: Array[Vector2] = []
	if world_polygon.is_empty():
		return samples

	var center := Vector2.ZERO
	for point in world_polygon:
		center += point
		samples.append(point)
	center /= float(world_polygon.size())
	samples.append(center)

	var point_count := world_polygon.size()
	for index in range(point_count):
		var start := world_polygon[index]
		var end := world_polygon[(index + 1) % point_count]
		samples.append(start.lerp(end, 0.5))
	return samples


func _footprint_fits_room(
	position_2d: Vector2,
	room_entry: Dictionary,
	local_polygon: PackedVector2Array,
	rotation_y: float,
) -> bool:
	var world_polygon := _transform_footprint_polygon(local_polygon, position_2d, rotation_y)
	for sample in _footprint_sample_points(world_polygon):
		if not _point_on_or_in_room_polygon(sample, room_entry):
			return false
	return true


func _nearest_room_edge_info(
	position_2d: Vector2,
	room_entry: Dictionary,
	max_distance := FURNITURE_WALL_SNAP_DISTANCE,
) -> Dictionary:
	var polygon := room_entry.get("polygon", PackedVector2Array()) as PackedVector2Array
	if polygon.size() < 3:
		return {}

	var centroid := room_entry.get("centroid", Vector2.ZERO) as Vector2
	var best_distance := max_distance
	var best_info := {}
	for index in range(polygon.size()):
		var start := polygon[index]
		var end := polygon[(index + 1) % polygon.size()]
		var candidate_point := Geometry2D.get_closest_point_to_segment(position_2d, start, end)
		var distance := candidate_point.distance_to(position_2d)
		if distance >= best_distance:
			continue

		var tangent := (end - start).normalized()
		if tangent.length() <= 0.0001:
			continue
		var inward_normal := Vector2(-tangent.y, tangent.x)
		if inward_normal.dot(centroid - candidate_point) < 0.0:
			inward_normal = -inward_normal

		best_distance = distance
		best_info = {
			"point": candidate_point,
			"distance": distance,
			"tangent": tangent,
			"inward_normal": inward_normal.normalized(),
		}
	return best_info


func _snap_footprint_to_wall(
	position_2d: Vector2,
	wall_info: Dictionary,
	local_polygon: PackedVector2Array,
	rotation_y: float,
) -> Vector2:
	if wall_info.is_empty():
		return position_2d

	var wall_point := wall_info.get("point", position_2d) as Vector2
	var inward_normal := wall_info.get("inward_normal", Vector2.ZERO) as Vector2
	if inward_normal.length() <= 0.0001:
		return position_2d

	var world_polygon := _transform_footprint_polygon(local_polygon, position_2d, rotation_y)
	var min_projection := INF
	for point in world_polygon:
		min_projection = min(min_projection, (point - wall_point).dot(inward_normal))
	if min_projection == INF:
		return position_2d
	return position_2d + inward_normal * (FURNITURE_WALL_CLEARANCE - min_projection)


func _project_polygon_onto_axis(axis: Vector2, polygon: PackedVector2Array) -> Vector2:
	var min_projection := INF
	var max_projection := -INF
	for point in polygon:
		var projection := axis.dot(point)
		min_projection = min(min_projection, projection)
		max_projection = max(max_projection, projection)
	return Vector2(min_projection, max_projection)


func _has_separating_axis(source: PackedVector2Array, target: PackedVector2Array) -> bool:
	for index in range(source.size()):
		var start := source[index]
		var end := source[(index + 1) % source.size()]
		var axis := (end - start).orthogonal()
		if axis.length() <= 0.0001:
			continue
		axis = axis.normalized()
		var source_range := _project_polygon_onto_axis(axis, source)
		var target_range := _project_polygon_onto_axis(axis, target)
		if source_range.y < target_range.x or target_range.y < source_range.x:
			return true
	return false


func _polygons_intersect(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	if a.size() < 3 or b.size() < 3:
		return false
	return not _has_separating_axis(a, b) and not _has_separating_axis(b, a)


func _intersects_existing_furniture(candidate_polygon: PackedVector2Array, ignored_root: Node3D = null) -> bool:
	for root in _furniture_roots:
		if not is_instance_valid(root):
			continue
		if root == ignored_root:
			continue
		var other_local := root.get_meta("furniture_collision_footprint_local", PackedVector2Array()) as PackedVector2Array
		if other_local.size() < 3:
			continue
		var other_polygon := _transform_footprint_polygon(
			other_local,
			Vector2(root.position.x, root.position.z),
			root.rotation_degrees.y
		)
		if _polygons_intersect(candidate_polygon, other_polygon):
			return true
	return false


func _validate_furniture_candidate(
	candidate: Vector2,
	room_entry: Dictionary,
	local_polygon: PackedVector2Array,
	collision_polygon: PackedVector2Array,
	rotation_y: float,
	ignored_root: Node3D = null,
) -> Dictionary:
	var fits_room := _footprint_fits_room(candidate, room_entry, local_polygon, rotation_y)
	var world_collision_polygon := _transform_footprint_polygon(collision_polygon, candidate, rotation_y)
	var overlaps := _intersects_existing_furniture(world_collision_polygon, ignored_root)
	return {
		"point": candidate,
		"fits_room": fits_room,
		"overlaps": overlaps,
		"valid": fits_room and not overlaps,
	}


func _snap_point_to_grid(position_2d: Vector2) -> Vector2:
	var origin := _plan_bounds.position
	return Vector2(
		round((position_2d.x - origin.x) / FURNITURE_GRID_STEP) * FURNITURE_GRID_STEP + origin.x,
		round((position_2d.y - origin.y) / FURNITURE_GRID_STEP) * FURNITURE_GRID_STEP + origin.y
	)


func _placement_candidate_offsets() -> Array[Vector2]:
	if not _placement_grid_offsets.is_empty():
		return _placement_grid_offsets

	_placement_grid_offsets.append(Vector2.ZERO)
	for ring in range(1, FURNITURE_GRID_SEARCH_RINGS + 1):
		_placement_grid_offsets.append(Vector2(ring, 0))
		_placement_grid_offsets.append(Vector2(-ring, 0))
		_placement_grid_offsets.append(Vector2(0, ring))
		_placement_grid_offsets.append(Vector2(0, -ring))
		for dx in range(-ring, ring + 1):
			for dy in range(-ring, ring + 1):
				if max(abs(dx), abs(dy)) != ring:
					continue
				if (dx == 0 and abs(dy) == ring) or (dy == 0 and abs(dx) == ring):
					continue
				_placement_grid_offsets.append(Vector2(dx, dy))
	return _placement_grid_offsets


func _plan_furniture_position(
	desired_point: Vector2,
	room_entry: Dictionary,
	model_id: String,
	rotation_y: float,
	ignored_root: Node3D = null,
	scale_factor := 1.0,
) -> Dictionary:
	var layout := _model_layout(model_id, scale_factor)
	if layout.is_empty():
		return {}

	var local_polygon := layout.get("footprint_local", PackedVector2Array()) as PackedVector2Array
	var collision_polygon := layout.get("collision_footprint_local", PackedVector2Array()) as PackedVector2Array
	if local_polygon.size() < 3 or collision_polygon.size() < 3:
		return {}

	var wall_info := _nearest_room_edge_info(desired_point, room_entry)
	var requested_point := _snap_point_to_grid(desired_point)
	if not wall_info.is_empty():
		requested_point = _snap_footprint_to_wall(requested_point, wall_info, local_polygon, rotation_y)
	var requested_validation := _validate_furniture_candidate(
		requested_point,
		room_entry,
		local_polygon,
		collision_polygon,
		rotation_y,
		ignored_root
	)
	if bool(requested_validation.get("valid", false)):
		return {
			"point": requested_point,
			"requested_point": requested_point,
			"valid": true,
			"requested_invalid": false,
			"overlap_requested": false,
		}

	var base_grid_point := _snap_point_to_grid(desired_point)
	for offset in _placement_candidate_offsets():
		var candidate := base_grid_point + offset * FURNITURE_GRID_STEP
		if not wall_info.is_empty():
			candidate = _snap_footprint_to_wall(candidate, wall_info, local_polygon, rotation_y)
		if candidate.is_equal_approx(requested_point):
			continue
		var validation := _validate_furniture_candidate(
			candidate,
			room_entry,
			local_polygon,
			collision_polygon,
			rotation_y,
			ignored_root
		)
		if not bool(validation.get("valid", false)):
			continue
		return {
			"point": candidate,
			"requested_point": requested_point,
			"valid": true,
			"requested_invalid": true,
			"overlap_requested": bool(requested_validation.get("overlaps", false)),
		}

	return {
		"point": requested_point,
		"requested_point": requested_point,
		"valid": false,
		"requested_invalid": true,
		"overlap_requested": bool(requested_validation.get("overlaps", false)),
	}


func _is_device_object(properties: Dictionary, raw_height: float) -> bool:
	return raw_height > 0.18 or String(properties.get("resourceId", "")) == "9999"


func _add_device_pin(
	device_id: String,
	device_name: String,
	device_kind: String,
	room_entry: Dictionary,
	position_2d: Vector2,
	icon_path: String,
	accent_color: Color,
	is_on: bool,
	device_index: int,
	temperature_c: int = DEVICE_TEMPERATURE_DEFAULT_C,
	air_quality_state: String = AIR_QUALITY_GOOD,
) -> void:
	var room_label := String(room_entry.get("label", "Room"))
	var pin_variant: Variant = DEVICE_PIN_SCENE.instantiate()
	if not pin_variant is Node3D:
		if pin_variant is Node:
			(pin_variant as Node).queue_free()
		return
	var pin := pin_variant as Node3D
	pin.position = Vector3(position_2d.x, FLOOR_SURFACE_Y, position_2d.y)
	var glow_room_polygon := PackedVector2Array()
	var room_polygon := room_entry.get("polygon", PackedVector2Array()) as PackedVector2Array
	for point in room_polygon:
		glow_room_polygon.append(point - position_2d)
	if pin.has_method("setup_pin"):
		pin.call(
			"setup_pin",
			icon_path,
			accent_color,
			is_on,
			room_label,
			device_kind,
			glow_room_polygon,
			temperature_c,
			air_quality_state
		)

	var fixture_root: Node3D = null
	if device_kind == DEVICE_KIND_AIR_CONDITIONER:
		fixture_root = _add_air_conditioner_fixture(room_entry, position_2d)

	_home_pivot.add_child(pin)
	_apply_device_pin_zoom_scale(pin)
	_device_pin_order.append(device_id)
	_device_pins[device_id] = {
		"id": device_id,
		"name": device_name,
		"kind": device_kind,
		"room_label": room_label,
		"pin": pin,
		"fixture_root": fixture_root,
		"accent_color": accent_color,
		"is_on": is_on,
		"temperature_c": temperature_c,
		"air_quality_state": air_quality_state,
		"pending_target": -1,
		"pending_progress": 0.0,
		"request_token": 0,
		"phase": float(device_index) * 0.8,
	}
	_update_device_pin_visual(device_id)


func _update_device_pin_visual(device_id: String) -> void:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty():
		return
	var is_on := bool(device.get("is_on", false))
	var is_pending := int(device.get("pending_target", -1)) != -1
	var accent_color := device.get("accent_color", DEVICE_PIN_ON_COLOR) as Color
	var pin: Variant = _device_pin_instance(device)
	if pin == null:
		return
	if pin.has_method("set_pin_state"):
		pin.call("set_pin_state", is_on, is_pending, accent_color)
	if pin.has_method("set_pending_progress"):
		pin.call("set_pending_progress", float(device.get("pending_progress", 0.0)))
	if pin.has_method("set_light_focus_active"):
		pin.call("set_light_focus_active", _light_focus_active)
	if pin.has_method("set_temperature_focus_active"):
		pin.call("set_temperature_focus_active", _temperature_focus_active)
	if pin.has_method("set_air_quality_focus_active"):
		pin.call("set_air_quality_focus_active", _air_quality_focus_active)
	if pin.has_method("set_temperature_c"):
		pin.call("set_temperature_c", int(device.get("temperature_c", DEVICE_TEMPERATURE_DEFAULT_C)))
	if pin.has_method("set_air_quality_state"):
		pin.call("set_air_quality_state", String(device.get("air_quality_state", AIR_QUALITY_GOOD)))
	if pin.has_method("set_air_quality_callout_visible"):
		pin.call(
			"set_air_quality_callout_visible",
			String(device.get("kind", "")) == DEVICE_KIND_AIR_PURIFIER
			and _air_quality_focus_active
		)
	if pin.has_method("set_temperature_callout_visible"):
		pin.call(
			"set_temperature_callout_visible",
			String(device.get("kind", "")) == DEVICE_KIND_AIR_CONDITIONER
			and _temperature_focus_active
			and is_on
			and not is_pending
		)
	_update_device_fixture_visual(device_id)


func _request_device_state_change(device_id: String, next_state: bool) -> void:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty() or int(device.get("pending_target", -1)) != -1:
		return
	if bool(device.get("is_on", false)) == next_state:
		return
	var request_token := int(device.get("request_token", 0)) + 1
	device["pending_target"] = 1 if next_state else 0
	device["pending_progress"] = 0.0
	device["request_token"] = request_token
	_device_pins[device_id] = device
	_update_device_pin_visual(device_id)


func _confirm_device_state_change(device_id: String, is_on: bool, request_token: int) -> void:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty() or int(device.get("request_token", 0)) != request_token:
		return
	device["is_on"] = is_on
	device["pending_target"] = -1
	device["pending_progress"] = 0.0
	_device_pins[device_id] = device
	_update_device_pin_visual(device_id)
	_notify_light_status()
	_notify_temperature_status()
	# Device label changed (on/off, temp). Republish so TalkBack reads the new
	# state next time focus lands on this device, and announce immediately so
	# users hear the change even if focus is elsewhere.
	_publish_accessibility_tree_debounced()
	_announce_for_accessibility(_describe_device_state_change(device, is_on))
	var pin: Variant = _device_pin_instance(device)
	if pin != null and pin.has_method("play_confirm_pulse"):
		pin.call("play_confirm_pulse")


func _describe_device_state_change(device: Dictionary, is_on: bool) -> String:
	var name := String(device.get("name", "Device"))
	var kind := String(device.get("kind", ""))
	match kind:
		"air_conditioner":
			return "%s turned %s" % [name, "on" if is_on else "off"]
		"air_purifier":
			return "%s %s" % [name, "running" if is_on else "stopped"]
		"camera":
			return "%s %s" % [name, "live" if is_on else "off"]
		_:
			return "%s turned %s" % [name, "on" if is_on else "off"]


func _toggle_device_pin(device_id: String) -> void:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty():
		return
	_request_device_state_change(device_id, not bool(device.get("is_on", false)))


func _find_device_pin_at_screen(screen_position: Vector2) -> String:
	if not is_instance_valid(_camera):
		return ""
	var closest_device_id := ""
	var closest_distance := DEVICE_PIN_TAP_RADIUS
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if device.is_empty():
			continue
		var pin: Variant = _device_pin_instance(device)
		if pin == null:
			continue
		if pin is Node3D and not (pin as Node3D).visible:
			continue
		var anchor_position: Vector3 = pin.global_position if pin is Node3D else Vector3.ZERO
		if pin.has_method("get_screen_anchor_position"):
			var anchor_variant: Variant = pin.call("get_screen_anchor_position")
			if anchor_variant is Vector3:
				anchor_position = anchor_variant as Vector3
		var pin_screen_position := _camera.unproject_position(anchor_position)
		var distance := pin_screen_position.distance_to(screen_position)
		if distance <= closest_distance:
			closest_distance = distance
			closest_device_id = device_id
	return closest_device_id


func _device_pin_instance(device: Dictionary):
	var pin_variant: Variant = device.get("pin", null)
	return pin_variant if pin_variant is Node else null


func _populate_sample_devices() -> void:
	var device_index := 0
	for room_label in SAMPLE_HOME_DEVICE_ROOMS:
		var room_entry := _room_entry_by_label(room_label)
		if room_entry.is_empty():
			continue
		var specs := SAMPLE_HOME_DEVICE_LAYOUT.get(room_label, []) as Array
		for spec_variant in specs:
			if not spec_variant is Dictionary:
				continue
			var spec := spec_variant as Dictionary
			var offset := spec.get("offset", Vector2.ZERO) as Vector2
			var device_id_str := String(spec.get("id", "device_%d" % device_index))
			_add_device_pin(
				device_id_str,
				String(spec.get("name", "Light %d" % (device_index + 1))),
				String(spec.get("kind", DEVICE_KIND_LIGHT)),
				room_entry,
				_sample_device_position(room_entry, offset),
				String(spec.get("icon_path", "")),
				spec.get("accent_color", DEVICE_PIN_ON_COLOR) as Color,
				bool(spec.get("is_on", false)),
				device_index,
				int(spec.get("temperature_c", DEVICE_TEMPERATURE_DEFAULT_C))
			)
			var stored := _device_pins.get(device_id_str, {}) as Dictionary
			if not stored.is_empty():
				if spec.has("image_path"):
					stored["image_path"] = String(spec.get("image_path", ""))
				if spec.has("image_asset"):
					stored["image_asset"] = String(spec.get("image_asset", ""))
				_device_pins[device_id_str] = stored
			device_index += 1


func _populate_sample_air_purifiers() -> void:
	for spec_variant in SAMPLE_HOME_AIR_PURIFIER_LAYOUT:
		if not spec_variant is Dictionary:
			continue
		var spec := spec_variant as Dictionary
		var room_entry := _room_entry_for_air_purifier_spec(spec)
		if room_entry.is_empty():
			continue
		var offset := spec.get("offset", Vector2.ZERO) as Vector2
		_add_device_pin(
			String(spec.get("id", "air_purifier_%d" % _device_pin_order.size())),
			String(spec.get("name", "Air Purifier")),
			DEVICE_KIND_AIR_PURIFIER,
			room_entry,
			_sample_device_position(room_entry, offset),
			DEVICE_PIN_AIR_PURIFIER_ICON_PATH,
			DEVICE_PIN_AIR_PURIFIER_COLOR,
			bool(spec.get("is_on", true)),
			_device_pin_order.size(),
			DEVICE_TEMPERATURE_DEFAULT_C,
			String(spec.get("quality_state", AIR_QUALITY_GOOD))
		)


func _room_entry_for_air_purifier_spec(spec: Dictionary) -> Dictionary:
	var room_label := String(spec.get("room_label", ""))
	if not room_label.is_empty():
		return _room_entry_by_label(room_label)

	var room_category := String(spec.get("room_category", ""))
	if room_category.is_empty():
		return {}

	var matches: Array[Dictionary] = []
	for room_entry in _room_entries:
		if String(room_entry.get("category", "")) == room_category:
			matches.append(room_entry)
	if matches.is_empty():
		return {}

	var selector := String(spec.get("room_selector", "first"))
	match selector:
		"rightmost":
			matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				return (a.get("centroid", Vector2.ZERO) as Vector2).x > (b.get("centroid", Vector2.ZERO) as Vector2).x
			)
		"leftmost":
			matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				return (a.get("centroid", Vector2.ZERO) as Vector2).x < (b.get("centroid", Vector2.ZERO) as Vector2).x
			)
		"largest":
			matches.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				return float(a.get("area", 0.0)) > float(b.get("area", 0.0))
			)
		_:
			pass

	return matches[0] if not matches.is_empty() else {}



func _room_entry_by_label(label: String) -> Dictionary:
	for room_entry in _room_entries:
		if String(room_entry.get("label", "")) == label:
			return room_entry
	return {}


func _sample_device_position(room_entry: Dictionary, offset_factor: Vector2) -> Vector2:
	var centroid := room_entry.get("centroid", Vector2.ZERO) as Vector2
	var bounds := room_entry.get("bounds", Rect2(centroid, Vector2.ONE)) as Rect2
	var polygon := room_entry.get("polygon", PackedVector2Array()) as PackedVector2Array
	for scale in [1.0, 0.72, 0.48, 0.24, 0.0]:
		var candidate := centroid + Vector2(
			bounds.size.x * offset_factor.x * float(scale),
			bounds.size.y * offset_factor.y * float(scale)
		)
		if polygon.is_empty() or Geometry2D.is_point_in_polygon(candidate, polygon):
			return candidate
	return centroid


func _add_air_conditioner_fixture(room_entry: Dictionary, desired_position_2d: Vector2):
	var bounds := room_entry.get("bounds", Rect2(desired_position_2d, Vector2.ONE)) as Rect2
	var wall_search_distance := maxf(bounds.size.x, bounds.size.y) * 0.9
	var wall_info := _nearest_room_edge_info(desired_position_2d, room_entry, wall_search_distance)
	if wall_info.is_empty():
		return null

	var inward_normal := wall_info.get("inward_normal", Vector2.UP) as Vector2
	var wall_point := wall_info.get("point", desired_position_2d) as Vector2
	var fixture_model = _instantiate_air_conditioner_fixture_model()
	if not fixture_model is Node3D:
		if fixture_model is Node:
			(fixture_model as Node).free()
		return null

	var fixture_root := Node3D.new()
	fixture_root.add_child(fixture_model)
	var anchor := wall_point + inward_normal * (AIR_CONDITIONER_TARGET_SIZE.z * 0.5 + AIR_CONDITIONER_WALL_CLEARANCE)
	fixture_root.position = Vector3(anchor.x, AIR_CONDITIONER_WALL_HEIGHT, anchor.y)
	fixture_root.look_at_from_position(
		fixture_root.position,
		fixture_root.position + Vector3(inward_normal.x, 0.0, inward_normal.y),
		Vector3.UP,
		true
	)
	var indicator = (fixture_model as Node3D).get_meta("ac_indicator_node", null)
	if indicator != null:
		fixture_root.set_meta("ac_indicator_node", indicator)
	_home_pivot.add_child(fixture_root)
	_register_focus_mesh_tree(fixture_root)
	return fixture_root


func _instantiate_air_conditioner_fixture_model():
	for asset_path in DEVICE_AIR_CONDITIONER_MODEL_CANDIDATE_PATHS:
		if not ResourceLoader.exists(asset_path):
			continue
		var packed := load(asset_path) as PackedScene
		if packed == null:
			continue
		var instance = packed.instantiate()
		if not instance is Node3D:
			if instance is Node:
				(instance as Node).free()
			continue
		var model := instance as Node3D
		_fit_air_conditioner_fixture_model(model)
		_disable_shadow_casting(model)
		return model
	return _create_fallback_air_conditioner_model()


func _fit_air_conditioner_fixture_model(model: Node3D) -> void:
	var aabb := _collect_node_aabb(model)
	if aabb.size == Vector3.ZERO:
		return
	var scale_factor := minf(
		AIR_CONDITIONER_TARGET_SIZE.x / maxf(aabb.size.x, 0.001),
		minf(
			AIR_CONDITIONER_TARGET_SIZE.y / maxf(aabb.size.y, 0.001),
			AIR_CONDITIONER_TARGET_SIZE.z / maxf(aabb.size.z, 0.001)
		)
	)
	model.scale = Vector3.ONE * scale_factor
	aabb = _collect_node_aabb(model)
	model.position -= aabb.get_center()


func _disable_shadow_casting(node: Node) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in node.get_children():
		_disable_shadow_casting(child)


func _air_conditioner_fixture_material(base_color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base_color
	material.roughness = 0.24
	material.metallic = 0.02
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _create_fallback_air_conditioner_model() -> Node3D:
	var root := Node3D.new()

	var shell := MeshInstance3D.new()
	var shell_mesh := BoxMesh.new()
	shell_mesh.size = AIR_CONDITIONER_TARGET_SIZE
	shell.mesh = shell_mesh
	shell.material_override = _air_conditioner_fixture_material(AIR_CONDITIONER_FALLBACK_COLOR)
	root.add_child(shell)

	var front_panel := MeshInstance3D.new()
	var front_mesh := BoxMesh.new()
	front_mesh.size = Vector3(
		AIR_CONDITIONER_TARGET_SIZE.x * 0.92,
		AIR_CONDITIONER_TARGET_SIZE.y * 0.52,
		AIR_CONDITIONER_TARGET_SIZE.z * 0.2
	)
	front_panel.mesh = front_mesh
	front_panel.position = Vector3(0.0, -AIR_CONDITIONER_TARGET_SIZE.y * 0.08, -AIR_CONDITIONER_TARGET_SIZE.z * 0.4)
	front_panel.material_override = _air_conditioner_fixture_material(AIR_CONDITIONER_FALLBACK_PANEL_COLOR)
	root.add_child(front_panel)

	for index in range(5):
		var slat := MeshInstance3D.new()
		var slat_mesh := BoxMesh.new()
		slat_mesh.size = Vector3(
			AIR_CONDITIONER_TARGET_SIZE.x * 0.76,
			0.008,
			AIR_CONDITIONER_TARGET_SIZE.z * 0.06
		)
		slat.mesh = slat_mesh
		slat.position = Vector3(
			0.0,
			-AIR_CONDITIONER_TARGET_SIZE.y * 0.2 + float(index) * AIR_CONDITIONER_TARGET_SIZE.y * 0.09,
			-AIR_CONDITIONER_TARGET_SIZE.z * 0.49
		)
		slat.material_override = _air_conditioner_fixture_material(AIR_CONDITIONER_FALLBACK_VENT_COLOR)
		root.add_child(slat)

	var indicator := MeshInstance3D.new()
	var indicator_mesh := BoxMesh.new()
	indicator_mesh.size = Vector3(AIR_CONDITIONER_TARGET_SIZE.x * 0.14, 0.012, 0.012)
	indicator.mesh = indicator_mesh
	indicator.position = Vector3(
		AIR_CONDITIONER_TARGET_SIZE.x * 0.3,
		-AIR_CONDITIONER_TARGET_SIZE.y * 0.18,
		-AIR_CONDITIONER_TARGET_SIZE.z * 0.52
	)
	indicator.material_override = _air_conditioner_fixture_material(Color(0.36, 0.4, 0.46, 1.0))
	root.add_child(indicator)
	root.set_meta("ac_indicator_node", indicator)

	_disable_shadow_casting(root)
	return root


func _update_device_fixture_visual(device_id: String) -> void:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty() or String(device.get("kind", "")) != DEVICE_KIND_AIR_CONDITIONER:
		return
	var fixture_root := device.get("fixture_root", null) as Node3D
	if not is_instance_valid(fixture_root):
		return
	var indicator := fixture_root.get_meta("ac_indicator_node", null) as MeshInstance3D
	if not is_instance_valid(indicator):
		return
	var material := indicator.material_override as StandardMaterial3D
	if material == null:
		return
	var is_on := bool(device.get("is_on", false))
	material.albedo_color = Color(0.55, 0.88, 1.0, 1.0) if is_on else Color(0.36, 0.4, 0.46, 1.0)
	material.emission_enabled = is_on
	material.emission = Color(0.55, 0.88, 1.0, 1.0)
	material.emission_energy_multiplier = 0.42 if is_on else 0.0


func set_device_state(device_id: String, is_on: bool) -> void:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty():
		return
	device["is_on"] = is_on
	device["pending_target"] = -1
	device["request_token"] = int(device.get("request_token", 0)) + 1
	_device_pins[device_id] = device
	_update_device_pin_visual(device_id)
	_notify_light_status()
	_notify_temperature_status()
	_publish_accessibility_tree_debounced()


func set_device_states(payload: String) -> void:
	var parsed: Variant = JSON.parse_string(payload)
	if not parsed is Array:
		return
	for item in parsed:
		if not item is Dictionary:
			continue
		var device_dict := item as Dictionary
		set_device_state(
			String(device_dict.get("id", "")),
			bool(device_dict.get("is_on", false))
		)


func _register_focus_mesh(mesh: MeshInstance3D) -> void:
	var surface_originals: Array = []
	var surface_focus: Array = []
	if mesh.mesh != null:
		for surface_index in range(mesh.mesh.get_surface_count()):
			var original := mesh.get_surface_override_material(surface_index)
			var active := mesh.get_active_material(surface_index)
			surface_originals.append(original)
			surface_focus.append(_make_focus_material_variant(active))
	_focus_material_entries.append({
		"mesh": mesh,
		"override": mesh.material_override,
		"overlay": mesh.material_overlay,
		"focus_override": _make_focus_material_variant(mesh.material_override),
		"focus_overlay": _make_focus_overlay_variant(mesh.material_overlay),
		"surface_originals": surface_originals,
		"surface_focus": surface_focus,
	})
	if _is_visualization_focus_active():
		var entry := _focus_material_entries[_focus_material_entries.size() - 1] as Dictionary
		_apply_focus_entry(mesh, entry, true)


func _register_focus_mesh_tree(node: Node) -> void:
	if node is MeshInstance3D:
		_register_focus_mesh(node as MeshInstance3D)
	for child in node.get_children():
		_register_focus_mesh_tree(child)


func _sync_focus_material_entry(mesh: MeshInstance3D) -> void:
	for index in range(_focus_material_entries.size()):
		var entry := _focus_material_entries[index] as Dictionary
		if entry.get("mesh", null) != mesh:
			continue
		entry["override"] = mesh.material_override
		entry["overlay"] = mesh.material_overlay
		entry["focus_override"] = _make_focus_material_variant(mesh.material_override)
		entry["focus_overlay"] = _make_focus_overlay_variant(mesh.material_overlay)
		var surface_originals: Array = []
		var surface_focus: Array = []
		if mesh.mesh != null:
			for surface_index in range(mesh.mesh.get_surface_count()):
				surface_originals.append(mesh.get_surface_override_material(surface_index))
				surface_focus.append(_make_focus_material_variant(mesh.get_active_material(surface_index)))
		entry["surface_originals"] = surface_originals
		entry["surface_focus"] = surface_focus
		_focus_material_entries[index] = entry
		_apply_focus_entry(mesh, entry, _is_visualization_focus_active())
		return


func _apply_focus_entry(mesh: MeshInstance3D, entry: Dictionary, focused: bool) -> void:
	if focused:
		mesh.material_override = entry.get("focus_override", entry.get("override", null))
		mesh.material_overlay = entry.get("focus_overlay", entry.get("overlay", null))
		var focus_surfaces := entry.get("surface_focus", []) as Array
		for surface_index in range(focus_surfaces.size()):
			var focus_mat := focus_surfaces[surface_index] as Material
			if focus_mat != null:
				mesh.set_surface_override_material(surface_index, focus_mat)
	else:
		mesh.material_override = entry.get("override", null)
		mesh.material_overlay = entry.get("overlay", null)
		var originals := entry.get("surface_originals", []) as Array
		for surface_index in range(originals.size()):
			mesh.set_surface_override_material(surface_index, originals[surface_index] as Material)


func _is_visualization_focus_active() -> bool:
	return _light_focus_active or _temperature_focus_active or _air_quality_focus_active or _camera_focus_active or _energy_focus_active


func _make_focus_material_variant(material: Material):
	if material == null:
		return null
	if material is StandardMaterial3D:
		return _make_focus_standard_material(material as StandardMaterial3D)
	if material is BaseMaterial3D:
		return _make_focus_base_material(material as BaseMaterial3D)
	return material.duplicate()


func _make_focus_overlay_variant(material: Material):
	if material == null:
		return null
	if material is StandardMaterial3D:
		return _make_focus_overlay_material(material as StandardMaterial3D)
	if material is BaseMaterial3D:
		return _make_focus_base_overlay_material(material as BaseMaterial3D)
	return material.duplicate()


func _make_focus_base_material(source: BaseMaterial3D) -> BaseMaterial3D:
	var material := source.duplicate() as BaseMaterial3D
	material.albedo_color = _grayscale_color(material.albedo_color, 0.55)
	material.emission = _grayscale_color(material.emission, 0.55)
	material.albedo_texture = _grayscale_texture(material.albedo_texture, 0.55)
	material.emission_texture = _grayscale_texture(material.emission_texture, 0.55)
	material.rim_tint = minf(material.rim_tint + 0.08, 1.0)
	return material


func _make_focus_base_overlay_material(source: BaseMaterial3D) -> BaseMaterial3D:
	var material := source.duplicate() as BaseMaterial3D
	var color := material.albedo_color
	color = _grayscale_color(color, 0.76)
	color.a = minf(maxf(color.a, 0.14), 0.26)
	material.albedo_color = color
	material.albedo_texture = _grayscale_texture(material.albedo_texture, 0.76)
	return material


func _make_focus_standard_material(source: StandardMaterial3D) -> StandardMaterial3D:
	if source.has_meta("pill_focus_solid_neutral"):
		var solid_info := FLOOR_FINISHES["solid_neutral"] as Dictionary
		var base_material := solid_info.get("material") as StandardMaterial3D
		var solid := base_material.duplicate(true) as StandardMaterial3D
		solid.cull_mode = BaseMaterial3D.CULL_DISABLED
		solid.albedo_color = PILL_FOCUS_FLOOR_COLOR
		solid.albedo_texture = null
		solid.normal_enabled = false
		solid.ao_enabled = false
		solid.uv1_triplanar = false
		solid.uv1_world_triplanar = false
		solid.roughness = 0.92
		return solid
	if source.has_meta("pill_focus_wall"):
		var wall := source.duplicate() as StandardMaterial3D
		var is_exterior := bool(source.get_meta("pill_focus_wall_exterior", false))
		if is_exterior:
			wall.albedo_color = PILL_FOCUS_WALL_EXTERIOR_COLOR
		else:
			var c := PILL_FOCUS_WALL_INTERIOR_COLOR
			wall.albedo_color = Color(c.r, c.g, c.b, INTERIOR_WALL_ALPHA)
		wall.albedo_texture = null
		wall.emission_enabled = false
		return wall
	var material := source.duplicate() as StandardMaterial3D
	material.albedo_color = _grayscale_color(material.albedo_color, 0.55)
	material.emission = _grayscale_color(material.emission, 0.55)
	material.albedo_texture = _grayscale_texture(material.albedo_texture, 0.55)
	material.emission_texture = _grayscale_texture(material.emission_texture, 0.55)
	material.rim_tint = minf(material.rim_tint + 0.08, 1.0)
	return material


func _make_focus_overlay_material(source: StandardMaterial3D) -> StandardMaterial3D:
	var material := source.duplicate() as StandardMaterial3D
	var color := material.albedo_color
	color = _grayscale_color(color, 0.76)
	color.a = minf(maxf(color.a, 0.14), 0.26)
	material.albedo_color = color
	material.albedo_texture = _grayscale_texture(material.albedo_texture, 0.76)
	return material


func _grayscale_color(color: Color, darken: float = 1.0) -> Color:
	var luma := color.r * 0.299 + color.g * 0.587 + color.b * 0.114
	var value := clampf(luma * darken, 0.0, 1.0)
	return Color(value, value, value, color.a)


func _grayscale_texture(texture: Texture2D, darken: float = 1.0) -> Texture2D:
	if texture == null:
		return null
	var cache_key := "%s|%.3f" % [texture.resource_path if not texture.resource_path.is_empty() else str(texture.get_rid().get_id()), darken]
	if _focus_grayscale_texture_cache.has(cache_key):
		return _focus_grayscale_texture_cache[cache_key] as Texture2D
	var image := texture.get_image()
	if image == null or image.is_empty():
		return texture
	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			image.set_pixel(x, y, _grayscale_color(color, darken))
	var grayscale := ImageTexture.create_from_image(image)
	_focus_grayscale_texture_cache[cache_key] = grayscale
	return grayscale


func _apply_light_focus_state() -> void:
	var visualization_active := _is_visualization_focus_active()
	for entry in _focus_material_entries:
		var mesh := entry.get("mesh", null) as MeshInstance3D
		if not is_instance_valid(mesh):
			continue
		_apply_focus_entry(mesh, entry, visualization_active)

	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		var pin: Variant = _device_pin_instance(device)
		if pin != null and pin.has_method("set_light_focus_active"):
			pin.call("set_light_focus_active", _light_focus_active)
		if pin != null and pin.has_method("set_temperature_focus_active"):
			pin.call("set_temperature_focus_active", _temperature_focus_active)
		if pin != null and pin.has_method("set_air_quality_focus_active"):
			pin.call("set_air_quality_focus_active", _air_quality_focus_active)
		if pin != null and pin.has_method("set_temperature_callout_visible"):
			pin.call(
				"set_temperature_callout_visible",
				String(device.get("kind", "")) == DEVICE_KIND_AIR_CONDITIONER
				and _temperature_focus_active
				and bool(device.get("is_on", false))
				and int(device.get("pending_target", -1)) == -1
			)
	_refresh_annotation_visibility()


func _home_skin_ui_models() -> Array:
	var models: Array = []
	for skin_id in HOME_SKIN_ORDER:
		var skin := HOME_SKINS.get(skin_id, {}) as Dictionary
		models.append({
			"id": skin_id,
			"label": String(skin.get("label", skin_id)),
			"color": skin.get("color", Color(0.3, 0.3, 0.34)),
		})
	return models


func _floor_finish_ui_models() -> Array:
	var models: Array = []
	for finish_id in FLOOR_FINISH_ORDER:
		var finish := FLOOR_FINISHES.get(finish_id, {}) as Dictionary
		models.append({
			"id": finish_id,
			"label": String(finish.get("label", finish_id)),
			"color": finish.get("swatch_color", Color(0.78, 0.78, 0.8)),
		})
	return models


func _on_skin_editor_edit_mode_requested(enabled: bool) -> void:
	_set_edit_mode(enabled)


func _on_home_skin_selected(skin_id: String) -> void:
	if _edit_mode:
		_preview_home_skin(skin_id)
	else:
		_apply_home_skin(skin_id)


func _on_room_finish_preview_requested(finish_id: String) -> void:
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		return
	_preview_room_finish(room_entry, finish_id)


func _on_room_finish_apply_requested() -> void:
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		return
	_commit_room_finish(room_entry)


func _on_room_finish_cancel_requested() -> void:
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		return
	_cancel_room_finish(room_entry)


func _on_apply_room_finish_to_all_requested() -> void:
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		return
	var finish_id := String(room_entry.get("pending_finish_id", room_entry.get("finish_id", "oak_light")))
	_apply_pending_finish_to_all_rooms(finish_id)


func _set_edit_mode(enabled: bool) -> void:
	if _edit_mode == enabled:
		return
	_set_selected_air_quality_device("")
	_clear_furniture_selection()
	_set_furniture_selection("")
	_edit_mode = enabled
	_pending_home_skin_id = _active_home_skin_id
	if enabled:
		_edit_mode_restore_rotation_y = _home_pivot.rotation_degrees.y
		_home_pivot.rotation_degrees.y = 0.0
		_plan_focus = Vector3(0.0, PLAN_FOCUS_HEIGHT, 0.0)
		_set_zoom_scale_immediate(1.0)
		for room_entry in _room_entries:
			room_entry["pending_finish_id"] = room_entry.get("finish_id", room_entry.get("home_default_finish_id", "oak_light"))
			_render_room_finish(room_entry, String(room_entry.get("pending_finish_id", room_entry.get("finish_id", "oak_light"))))
	if not enabled:
		_cancel_all_pending_room_finishes(false)
		_home_pivot.rotation_degrees.y = _edit_mode_restore_rotation_y
		_set_selected_room("")
		_clear_floor_editor_selection()
	_refresh_annotation_visibility()
	if is_instance_valid(_skin_editor_ui):
		_skin_editor_ui.set_edit_mode(enabled)
		if not enabled:
			_skin_editor_ui.clear_selected_room()
	_refresh_skin_editor_ui()
	_update_camera_for_viewport()


func _set_furniture_edit_mode(enabled: bool) -> void:
	if _furniture_edit_mode == enabled:
		return
	_furniture_edit_mode = enabled
	_set_selected_air_quality_device("")
	_clear_furniture_selection()
	if not enabled:
		_set_furniture_selection("")


func _set_room_labels_visible(is_visible: bool) -> void:
	for label_node in _label_nodes:
		if is_instance_valid(label_node):
			label_node.visible = is_visible


func _set_device_pins_visible(is_visible: bool) -> void:
	var focused_kind := _focused_device_kind()
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		var device_kind := String(device.get("kind", ""))
		var pin: Variant = _device_pin_instance(device)
		var pin_visible := is_visible and (focused_kind.is_empty() or device_kind == focused_kind)
		if pin != null and pin is Node3D:
			(pin as Node3D).visible = pin_visible
		var fixture_root := device.get("fixture_root", null) as Node3D
		if is_instance_valid(fixture_root):
			fixture_root.visible = is_visible and (
				focused_kind.is_empty()
				or (focused_kind == DEVICE_KIND_AIR_CONDITIONER and device_kind == DEVICE_KIND_AIR_CONDITIONER)
			)


func _focused_device_kind() -> String:
	if _air_quality_focus_active:
		return DEVICE_KIND_AIR_PURIFIER
	if _temperature_focus_active:
		return DEVICE_KIND_AIR_CONDITIONER
	if _light_focus_active:
		return DEVICE_KIND_LIGHT
	if _camera_focus_active:
		return DEVICE_KIND_CAMERA
	return ""


func _refresh_annotation_visibility() -> void:
	_set_room_labels_visible(not _edit_mode and not _air_quality_focus_active)
	_set_device_pins_visible(not _edit_mode)


func _apply_home_skin(skin_id: String) -> void:
	if not HOME_SKINS.has(skin_id):
		return
	_active_home_skin_id = skin_id
	_pending_home_skin_id = skin_id
	for room_entry in _room_entries:
		var finish_id := _default_finish_for_room(room_entry)
		room_entry["home_default_finish_id"] = finish_id
		room_entry["finish_id"] = finish_id
		room_entry["pending_finish_id"] = finish_id
		_render_room_finish(room_entry, finish_id)
	_save_floor_finish_state()
	if is_instance_valid(_skin_editor_ui):
		_skin_editor_ui.set_active_skin(skin_id)
	_refresh_skin_editor_ui()


func _preview_home_skin(skin_id: String) -> void:
	if not HOME_SKINS.has(skin_id):
		return
	var previous_skin_id := _active_home_skin_id
	_active_home_skin_id = skin_id
	_pending_home_skin_id = skin_id
	for room_entry in _room_entries:
		var finish_id := _default_finish_for_room(room_entry)
		room_entry["home_default_finish_id"] = finish_id
		room_entry["pending_finish_id"] = finish_id
		_render_room_finish(room_entry, finish_id)
	_active_home_skin_id = previous_skin_id
	if is_instance_valid(_skin_editor_ui):
		_skin_editor_ui.set_active_skin(skin_id)
	if not _selected_room_id.is_empty() and _rooms_by_id.has(_selected_room_id):
		_notify_floor_editor_selection(_rooms_by_id[_selected_room_id] as Dictionary)
	_refresh_skin_editor_ui()


func _selected_room_entry() -> Dictionary:
	return _rooms_by_id.get(_selected_room_id, {}) as Dictionary


func _set_selected_room(room_id: String) -> void:
	if room_id == _selected_room_id:
		_refresh_skin_editor_ui()
		if _edit_mode and _rooms_by_id.has(room_id):
			_notify_floor_editor_selection(_rooms_by_id[room_id] as Dictionary)
		return

	if _rooms_by_id.has(_selected_room_id):
		var previous := _rooms_by_id[_selected_room_id] as Dictionary
		previous["is_selected"] = false
		var previous_floor := previous.get("floor_node", null) as MeshInstance3D
		if is_instance_valid(previous_floor):
			previous_floor.material_overlay = null
			_sync_focus_material_entry(previous_floor)

	_selected_room_id = room_id

	if _rooms_by_id.has(room_id):
		var next := _rooms_by_id[room_id] as Dictionary
		next["is_selected"] = true
		var next_floor := next.get("floor_node", null) as MeshInstance3D
		if is_instance_valid(next_floor):
			next_floor.material_overlay = _selection_overlay_material()
			_sync_focus_material_entry(next_floor)
		if _edit_mode:
			_notify_floor_editor_selection(next)
	elif _edit_mode:
		_clear_floor_editor_selection()

	_refresh_skin_editor_ui()


func _refresh_skin_editor_ui() -> void:
	if not is_instance_valid(_skin_editor_ui):
		return
	_skin_editor_ui.set_active_skin(_pending_home_skin_id if _edit_mode else _active_home_skin_id)
	if not _edit_mode or _selected_room_id.is_empty():
		_skin_editor_ui.clear_selected_room()
		return
	var room_entry := _selected_room_entry()
	if room_entry.is_empty():
		_skin_editor_ui.clear_selected_room()
		return
	var pending_finish_id := String(room_entry.get("pending_finish_id", room_entry.get("finish_id", "oak_light")))
	_skin_editor_ui.show_selected_room(String(room_entry.get("label", "Room")), pending_finish_id)
	_skin_editor_ui.set_selected_finish(pending_finish_id)


func _begin_room_edit(room_entry: Dictionary) -> void:
	_notify_floor_editor_selection(room_entry)
	_refresh_skin_editor_ui()


func _preview_room_finish(room_entry: Dictionary, finish_id: String) -> void:
	room_entry["pending_finish_id"] = finish_id
	_render_room_finish(room_entry, finish_id)
	_notify_floor_editor_selection(room_entry)
	_refresh_skin_editor_ui()


func _commit_room_finish(room_entry: Dictionary) -> void:
	room_entry["finish_id"] = room_entry.get("pending_finish_id", room_entry.get("finish_id", "oak_light"))
	room_entry["home_default_finish_id"] = room_entry.get("finish_id", room_entry.get("home_default_finish_id", "oak_light"))
	_render_room_finish(room_entry, String(room_entry.get("finish_id", "oak_light")))
	_notify_floor_editor_selection(room_entry)
	_refresh_skin_editor_ui()


func _cancel_room_finish(room_entry: Dictionary, refresh_ui := true) -> void:
	var finish_id := String(room_entry.get("finish_id", room_entry.get("home_default_finish_id", "oak_light")))
	room_entry["pending_finish_id"] = finish_id
	_render_room_finish(room_entry, finish_id)
	_notify_floor_editor_selection(room_entry)
	if refresh_ui:
		_refresh_skin_editor_ui()


func _apply_pending_finish_to_all_rooms(finish_id: String) -> void:
	for room_entry in _room_entries:
		room_entry["pending_finish_id"] = finish_id
		_render_room_finish(room_entry, finish_id)
	if not _selected_room_id.is_empty() and _rooms_by_id.has(_selected_room_id):
		_notify_floor_editor_selection(_rooms_by_id[_selected_room_id] as Dictionary)
	_refresh_skin_editor_ui()


func _commit_all_pending_room_finishes() -> void:
	_active_home_skin_id = _pending_home_skin_id
	for room_entry in _room_entries:
		var finish_id := String(room_entry.get("pending_finish_id", room_entry.get("finish_id", "oak_light")))
		room_entry["finish_id"] = finish_id
		room_entry["home_default_finish_id"] = finish_id
		_render_room_finish(room_entry, finish_id)
	_save_floor_finish_state()
	if not _selected_room_id.is_empty() and _rooms_by_id.has(_selected_room_id):
		_notify_floor_editor_selection(_rooms_by_id[_selected_room_id] as Dictionary)
	_refresh_skin_editor_ui()


func _cancel_all_pending_room_finishes(refresh_ui := true) -> void:
	_pending_home_skin_id = _active_home_skin_id
	for room_entry in _room_entries:
		var finish_id := String(room_entry.get("finish_id", room_entry.get("home_default_finish_id", "oak_light")))
		room_entry["pending_finish_id"] = finish_id
		room_entry["home_default_finish_id"] = finish_id
		_render_room_finish(room_entry, finish_id)
	if refresh_ui:
		if not _selected_room_id.is_empty() and _rooms_by_id.has(_selected_room_id):
			_notify_floor_editor_selection(_rooms_by_id[_selected_room_id] as Dictionary)
		_refresh_skin_editor_ui()


func _plugin_singleton():
	if not Engine.has_singleton(APP_PLUGIN_NAME):
		return null
	return Engine.get_singleton(APP_PLUGIN_NAME)


func _plugin_has_java_method(plugin: Variant, method_name: String) -> bool:
	if plugin == null:
		return false
	if plugin.has_method("has_java_method"):
		return bool(plugin.call("has_java_method", method_name))
	return false


func _notify_light_status() -> void:
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_NOTIFY_LIGHT_STATUS):
		return
	plugin.call(JAVA_METHOD_NOTIFY_LIGHT_STATUS, _count_on_lights(), _count_total_lights())


func _notify_temperature_status() -> void:
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_NOTIFY_TEMPERATURE_STATUS):
		return
	var temperature_range := _active_air_conditioner_temperature_range()
	plugin.call(
		JAVA_METHOD_NOTIFY_TEMPERATURE_STATUS,
		int(temperature_range.get("min", 0)),
		int(temperature_range.get("max", 0)),
		_count_on_air_conditioners(),
		_count_total_air_conditioners()
	)


func _notify_floor_editor_selection(room_entry: Dictionary) -> void:
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_SHOW_FLOOR_EDITOR_SELECTION):
		return
	plugin.call(
		JAVA_METHOD_SHOW_FLOOR_EDITOR_SELECTION,
		String(room_entry.get("id", "")),
		String(room_entry.get("label", "Room")),
		String(room_entry.get("finish_id", "oak_light")),
		String(room_entry.get("pending_finish_id", room_entry.get("finish_id", "oak_light")))
	)


func _clear_floor_editor_selection() -> void:
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_CLEAR_FLOOR_EDITOR_SELECTION):
		return
	plugin.call(JAVA_METHOD_CLEAR_FLOOR_EDITOR_SELECTION)


func _clear_android_furniture_catalog_selection() -> void:
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_CLEAR_FURNITURE_CATALOG_SELECTION):
		return
	plugin.call(JAVA_METHOD_CLEAR_FURNITURE_CATALOG_SELECTION)


func _count_total_lights() -> int:
	var total := 0
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if String(device.get("kind", "")) == DEVICE_KIND_LIGHT:
			total += 1
	return total


func _count_on_lights() -> int:
	var on_count := 0
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if String(device.get("kind", "")) == DEVICE_KIND_LIGHT and bool(device.get("is_on", false)):
			on_count += 1
	return on_count


func _count_total_air_conditioners() -> int:
	var total := 0
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if String(device.get("kind", "")) == DEVICE_KIND_AIR_CONDITIONER:
			total += 1
	return total


func _count_on_air_conditioners() -> int:
	var on_count := 0
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if String(device.get("kind", "")) == DEVICE_KIND_AIR_CONDITIONER and bool(device.get("is_on", false)):
			on_count += 1
	return on_count


func _active_air_conditioner_temperature_range() -> Dictionary:
	var has_temperature := false
	var min_temperature := 0
	var max_temperature := 0
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		if String(device.get("kind", "")) != DEVICE_KIND_AIR_CONDITIONER:
			continue
		if not bool(device.get("is_on", false)):
			continue
		var temperature_c := int(device.get("temperature_c", DEVICE_TEMPERATURE_DEFAULT_C))
		if not has_temperature:
			min_temperature = temperature_c
			max_temperature = temperature_c
			has_temperature = true
			continue
		min_temperature = mini(min_temperature, temperature_c)
		max_temperature = maxi(max_temperature, temperature_c)
	return {
		"min": min_temperature if has_temperature else 0,
		"max": max_temperature if has_temperature else 0,
	}


func _show_device_control_popup(device_id: String) -> bool:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty():
		print("[SmartHome] show_device_control_popup missing device: %s" % device_id)
		return false
	if String(device.get("kind", "")) == DEVICE_KIND_AIR_PURIFIER:
		_set_selected_air_quality_device(device_id)
		return true
	if String(device.get("kind", "")) == DEVICE_KIND_CAMERA:
		_show_single_camera_callout(device_id)
		return true
	_set_selected_air_quality_device("")
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_SHOW_DEVICE_CONTROL_POPUP):
		print("[SmartHome] show_device_control_popup unavailable; falling back for %s" % device_id)
		return false
	print("[SmartHome] show_device_control_popup called for %s" % device_id)
	plugin.call(
		JAVA_METHOD_SHOW_DEVICE_CONTROL_POPUP,
		device_id,
		String(device.get("room_label", "Room")),
		String(device.get("name", "Device")),
		String(device.get("kind", DEVICE_KIND_LIGHT)),
		bool(device.get("is_on", false)),
		int(device.get("temperature_c", 0))
	)
	return true


# ---------------------------------------------------------------------------
# Accessibility (TalkBack) — see scripts/accessibility_tree_builder.gd and
# android-app/.../accessibility/* for the full data flow. We expose the floor
# → room → device hierarchy as virtual TalkBack nodes; swiping right walks
# them in DFS order (app → floor → room1 → devices in room1 → room2 → …).
# ---------------------------------------------------------------------------

# Triggered every _process tick. Compares camera origin / basis and pivot
# Y-rotation against the last published snapshot; if any moved beyond a tiny
# epsilon, schedule a debounced republish so TalkBack focus rectangles stay
# aligned with the visual pin / room positions during pan, pinch and twist.
func _check_accessibility_camera_dirty() -> void:
	if not _a11y_initial_publish_done:
		return
	if not is_instance_valid(_camera) or not is_instance_valid(_home_pivot):
		return
	var camera_origin := _camera.global_transform.origin
	var camera_basis_x := _camera.global_transform.basis.x
	var pivot_rot_y := _home_pivot.rotation.y
	if (
		camera_origin.distance_squared_to(_a11y_last_camera_origin) > 0.000004
		or camera_basis_x.distance_squared_to(_a11y_last_camera_basis_x) > 0.000004
		or absf(pivot_rot_y - _a11y_last_pivot_rotation_y) > 0.002
		or absf(_zoom_scale - _a11y_last_zoom_scale) > 0.002
	):
		_publish_accessibility_tree_debounced()


func _publish_accessibility_tree_debounced() -> void:
	# Coalesce bursts of state changes (e.g. building 30 device pins in a
	# single frame) into a single tree publish. 200 ms is conservative
	# enough that ExploreByTouchHelper's invalidateRoot() doesn't churn
	# every frame during the intro animation or pinch-zoom — frequent
	# republishes can briefly hide the overlay's accessibility nodes from
	# TalkBack while the helper rebuilds, which is what the
	# "can't navigate to anything" symptom looks like.
	if _a11y_publish_timer != null:
		# Existing timer will fire shortly — let it.
		return
	if get_tree() == null:
		return
	_a11y_publish_timer = get_tree().create_timer(0.2)
	_a11y_publish_timer.timeout.connect(_publish_accessibility_tree, CONNECT_ONE_SHOT)


func _publish_accessibility_tree() -> void:
	_a11y_publish_timer = null
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_PUBLISH_ACCESSIBILITY_TREE):
		return
	if _room_entries.is_empty():
		# Nothing to publish yet; first publish will happen once rooms exist.
		return
	var floor_name := _a11y_floor_name
	if floor_name.is_empty():
		floor_name = "1F"  # JSON contains exactly one floor today.
	var tree := AccessibilityTreeBuilder.build(
		_room_entries,
		_device_pins,
		_device_pin_order,
		floor_name,
		_camera,
		get_viewport(),
	)
	var dfs_order: Array = tree.get("dfs_order", []) as Array
	# Defensive: never publish a tree that would empty the host. If the
	# builder somehow produces no nodes (e.g. transient camera state), keep
	# the helper's previous tree alive so TalkBack can still navigate.
	if dfs_order.size() < 2:
		print("[SmartHome] a11y publish skipped — only %d nodes in tree" % dfs_order.size())
		return
	plugin.call(JAVA_METHOD_PUBLISH_ACCESSIBILITY_TREE, JSON.stringify(tree))
	# Trace which nodes went out so we can diagnose missing-tree symptoms
	# from logcat without re-deploying.
	print("[SmartHome] a11y publish: %d nodes (root=%s)" % [dfs_order.size(), String(tree.get("root_id", ""))])
	_a11y_initial_publish_done = true
	# Snapshot transforms so the per-frame dirty check only triggers on real
	# subsequent moves.
	if is_instance_valid(_camera):
		_a11y_last_camera_origin = _camera.global_transform.origin
		_a11y_last_camera_basis_x = _camera.global_transform.basis.x
	if is_instance_valid(_home_pivot):
		_a11y_last_pivot_rotation_y = _home_pivot.rotation.y
	_a11y_last_zoom_scale = _zoom_scale


func _announce_for_accessibility(text: String) -> void:
	if text.is_empty():
		return
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_ANNOUNCE_FOR_ACCESSIBILITY):
		return
	plugin.call(JAVA_METHOD_ANNOUNCE_FOR_ACCESSIBILITY, text)


# Parses a node id of the form "device:<uuid>" / "room:<uuid>" / "floor:<name>"
# / "app". Returns ["", ""] for unrecognised input.
static func _parse_accessibility_node_id(node_id: String) -> Array:
	var sep := node_id.find(":")
	if sep < 0:
		return [node_id, ""]
	return [node_id.substr(0, sep), node_id.substr(sep + 1)]


func _on_accessibility_focus_changed(node_id: String) -> void:
	if node_id == _a11y_focused_node_id:
		return
	_a11y_focused_node_id = node_id
	var parts := _parse_accessibility_node_id(node_id)
	var kind: String = parts[0]
	var raw_id: String = parts[1]
	# IMPORTANT: focus changes must NOT open the device popup (that's reserved
	# for activation = TalkBack double-tap). We only mirror the focus visually
	# so the sighted user / accessibility tester can see what TalkBack reads.
	match kind:
		"device":
			# Reuse the existing per-pin highlight if the API exists; falling
			# back to a no-op keeps focus traversal working even when shaders
			# aren't ready yet (e.g. during the intro animation).
			var device := _device_pins.get(raw_id, {}) as Dictionary
			if device.is_empty():
				return
			var pin: Variant = device.get("pin", null)
			if pin != null and pin.has_method("set_accessibility_focus"):
				pin.call("set_accessibility_focus", true)
		"room":
			# No room-level highlight wired today; placeholder for future
			# spotlight / outline. Tap-style zoom would be too disruptive on
			# every swipe-right.
			pass
		_:
			pass


func _on_accessibility_activate(node_id: String) -> void:
	var parts := _parse_accessibility_node_id(node_id)
	var kind: String = parts[0]
	var raw_id: String = parts[1]
	match kind:
		"device":
			# Direct on/off toggle — bypasses the visual control popup so
			# the user gets a single, predictable "double tap to activate"
			# / "double tap to deactivate" interaction. Confirmation
			# announcement comes from _confirm_device_state_change.
			_toggle_device_pin(raw_id)
		"room":
			# Zoom the camera into the activated room so the visual state
			# matches what TalkBack just announced. The camera move will
			# trigger _check_accessibility_camera_dirty → republish, which
			# refreshes pin bounds for the new view.
			var room_entry := _rooms_by_id.get(raw_id, {}) as Dictionary
			if not room_entry.is_empty():
				_announce_for_accessibility(
					"%s zoomed in" % String(room_entry.get("label", "Room"))
				)
				_zoom_to_room(room_entry)
		"floor", "app":
			# Reset to the overview shot so the user can re-orient. Same
			# behaviour as a double-tap on empty floor area.
			_announce_for_accessibility("Overview")
			_zoom_to_full_view()
		_:
			pass


func _set_selected_air_quality_device(device_id: String) -> void:
	var next_device_id := device_id
	if not next_device_id.is_empty():
		var device := _device_pins.get(next_device_id, {}) as Dictionary
		if device.is_empty() or String(device.get("kind", "")) != DEVICE_KIND_AIR_PURIFIER:
			next_device_id = ""
	if _selected_air_quality_device_id == next_device_id:
		return

	var previous_device_id := _selected_air_quality_device_id
	_selected_air_quality_device_id = next_device_id

	if not previous_device_id.is_empty():
		_update_device_pin_visual(previous_device_id)
	if not next_device_id.is_empty():
		_update_device_pin_visual(next_device_id)


func get_device_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for device_id in _device_pin_order:
		ids.append(device_id)
	return ids


func _model_for_category(category: String) -> String:
	# Sofa-only catalog: every category maps to a sofa variant. Different
	# categories deterministically pick different sofa silhouettes so the
	# sample home shows visual variety without random churn between runs.
	var fallback := SOFA_VARIANT_IDS[0] as String
	match category:
		"BEDROOM":
			return _sofa_variant_or_fallback(SOFA_VARIANT_IDS[1], fallback)
		"CLOSET":
			return _sofa_variant_or_fallback(SOFA_VARIANT_IDS[2], fallback)
		"KITCHEN":
			return _sofa_variant_or_fallback(SOFA_VARIANT_IDS[3], fallback)
		"BATHROOM":
			return _sofa_variant_or_fallback(SOFA_VARIANT_IDS[4], fallback)
		_:
			return _sofa_variant_or_fallback(SOFA_VARIANT_IDS[0], fallback)


func _sofa_variant_or_fallback(preferred: String, fallback: String) -> String:
	if _model_paths.has(preferred):
		return preferred
	if _model_paths.has(fallback):
		return fallback
	return _default_model_id_for_kind(MODEL_KIND_SOFA, fallback)


func _find_room_entry(point: Vector2) -> Dictionary:
	for room_entry in _room_entries:
		var polygon := room_entry.get("polygon", PackedVector2Array()) as PackedVector2Array
		if Geometry2D.is_point_in_polygon(point, polygon):
			return room_entry
	return {}


func _smartthings_room_label(category: String, category_rank: int, category_total: int, is_largest_room: bool) -> String:
	match category:
		"KITCHEN":
			if is_largest_room or category_rank == 0:
				return "Living"
			return "Kitchen" if category_rank == 1 else "Kitchen %d" % category_rank
		"BEDROOM":
			if category_rank == 0:
				return "Master"
			if category_rank == 1:
				return "Study"
			return "Bedroom" if category_total <= 3 else "Bedroom %d" % (category_rank - 1)
		"BATHROOM":
			return "Bath" if category_total == 1 else "Bath %d" % (category_rank + 1)
		"CLOSET":
			return "Closet"
		_:
			return _format_category(category)


func _load_floor_plan() -> Dictionary:
	if not FileAccess.file_exists(FLOOR_PLAN_PATH):
		return {}
	var json_text := FileAccess.get_file_as_string(FLOOR_PLAN_PATH)
	if json_text.is_empty():
		return {}
	var parsed: Variant = JSON.parse_string(json_text)
	return parsed if parsed is Dictionary else {}


func _load_floor_finish_state() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(FLOOR_FINISH_STATE_PATH) != OK:
		return {}
	var room_finishes := {}
	if config.has_section("rooms"):
		for room_id in config.get_section_keys("rooms"):
			room_finishes[room_id] = String(config.get_value("rooms", room_id, "oak_light"))
	return {
		"home_skin_id": String(config.get_value("meta", "home_skin_id", _active_home_skin_id)),
		"room_finishes": room_finishes,
	}


func _restore_saved_room_finishes(state: Dictionary) -> void:
	var room_finishes := state.get("room_finishes", {}) as Dictionary
	if room_finishes.is_empty():
		return
	for room_entry in _room_entries:
		var room_id := String(room_entry.get("id", ""))
		var finish_id := String(room_finishes.get(room_id, room_entry.get("finish_id", "oak_light")))
		if not FLOOR_FINISHES.has(finish_id):
			continue
		room_entry["finish_id"] = finish_id
		room_entry["pending_finish_id"] = finish_id
		room_entry["home_default_finish_id"] = finish_id
		_render_room_finish(room_entry, finish_id)


func _save_floor_finish_state() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "home_skin_id", _active_home_skin_id)
	for room_entry in _room_entries:
		var room_id := String(room_entry.get("id", ""))
		if room_id.is_empty():
			continue
		config.set_value("rooms", room_id, String(room_entry.get("finish_id", "oak_light")))
	var save_result := config.save(FLOOR_FINISH_STATE_PATH)
	if save_result != OK:
		push_warning("Unable to save floor finish state to %s (error %s)." % [FLOOR_FINISH_STATE_PATH, save_result])


func _primary_floor(plan: Dictionary) -> Dictionary:
	var floors: Array = plan.get("floors", [])
	if floors is Array and not floors.is_empty() and floors[0] is Dictionary:
		return floors[0]
	return {}


func _compute_floor_bounds(floor: Dictionary) -> Rect2:
	var initialized := false
	var min_point := Vector2.ZERO
	var max_point := Vector2.ZERO
	for room in floor.get("rooms", []):
		if not room is Dictionary:
			continue
		for coord in (((room as Dictionary).get("plane", {}) as Dictionary).get("coordinates", [])):
			var point := _raw_xz(coord)
			if not initialized:
				min_point = point
				max_point = point
				initialized = true
			else:
				min_point.x = min(min_point.x, point.x)
				min_point.y = min(min_point.y, point.y)
				max_point.x = max(max_point.x, point.x)
				max_point.y = max(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point) if initialized else Rect2(Vector2.ZERO, Vector2.ZERO)


func _raw_xz(point: Variant) -> Vector2:
	if point is Array and point.size() >= 3:
		return Vector2(float(point[0]), float(point[2]))
	return Vector2.ZERO


func _scaled_point(point: Variant) -> Vector2:
	return (_raw_xz(point) - _plan_center_raw) * FLOOR_PLAN_SCALE


func _scaled_polygon(points_data: Variant) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	if not points_data is Array:
		return polygon
	for point in points_data:
		polygon.append(_scaled_point(point))
	return polygon


func _build_polygon_mesh(polygon: PackedVector2Array) -> ArrayMesh:
	var triangulated := Geometry2D.triangulate_polygon(polygon)
	if triangulated.is_empty():
		var reversed := PackedVector2Array()
		for index in range(polygon.size() - 1, -1, -1):
			reversed.append(polygon[index])
		polygon = reversed
		triangulated = Geometry2D.triangulate_polygon(polygon)

	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	for point in polygon:
		vertices.append(Vector3(point.x, 0.0, point.y))
		normals.append(Vector3.UP)
		# Keep UVs in plan/world space so floor pattern size stays readable and scales naturally with camera zoom.
		uvs.append(point)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = triangulated

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _segment_key(from: Vector2, to: Vector2) -> String:
	var start := from
	var finish := to
	if finish.x < start.x or (is_equal_approx(finish.x, start.x) and finish.y < start.y):
		start = to
		finish = from
	return "%.3f,%.3f|%.3f,%.3f" % [start.x, start.y, finish.x, finish.y]


func _wall_height_from_points(points_data: Array) -> float:
	var max_height := 0.0
	for point in points_data:
		if point is Array and point.size() >= 2:
			max_height = max(max_height, float(point[1]) * FLOOR_HEIGHT_SCALE)
	return max(max_height, INTERIOR_WALL_HEIGHT)


func _bounds_for_polygon(polygon: PackedVector2Array) -> Rect2:
	if polygon.is_empty():
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var min_point := polygon[0]
	var max_point := polygon[0]
	for point in polygon:
		min_point.x = min(min_point.x, point.x)
		min_point.y = min(min_point.y, point.y)
		max_point.x = max(max_point.x, point.x)
		max_point.y = max(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)


func _polygon_area(polygon: PackedVector2Array) -> float:
	var area := 0.0
	for index in range(polygon.size()):
		var current := polygon[index]
		var next := polygon[(index + 1) % polygon.size()]
		area += current.x * next.y - next.x * current.y
	return area * 0.5


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
	if abs(signed_area) <= 0.0001:
		for point in polygon:
			centroid += point
		return centroid / float(polygon.size())
	return centroid / (3.0 * signed_area)


func _room_color(properties: Dictionary) -> Color:
	var category := String(properties.get("category", "ROOM"))
	return Color.from_string("#%s" % String(properties.get("color", "")), _default_room_color(category))


func _default_room_color(category: String) -> Color:
	match category:
		"BEDROOM":
			return Color(0.85, 0.92, 0.86)
		"KITCHEN":
			return Color(0.78, 0.88, 0.98)
		"BATHROOM":
			return Color(0.93, 0.89, 0.95)
		"CLOSET":
			return Color(0.9, 0.94, 0.88)
		_:
			return Color(0.92, 0.92, 0.92)


func _smartthings_room_color(label: String, category: String, source_color: Color) -> Color:
	match label:
		"Living":
			return Color(0.72, 0.82, 0.94)
		"Master":
			return Color(0.71, 0.86, 0.88)
		"Study":
			return Color(0.73, 0.84, 0.72)
		"Kitchen":
			return Color(0.86, 0.77, 0.84)
		"Closet":
			return Color(0.8, 0.87, 0.72)
		"Bath":
			return Color(0.92, 0.88, 0.94)
		"Bath 1":
			return Color(0.92, 0.88, 0.94)
		"Bath 2":
			return Color(0.94, 0.9, 0.95)
		_:
			if category == "BEDROOM":
				return Color(0.78, 0.87, 0.76)
			if category == "BATHROOM":
				return Color(0.93, 0.89, 0.95)
			if category == "CLOSET":
				return Color(0.82, 0.88, 0.74)
			if category == "KITCHEN":
				return Color(0.75, 0.83, 0.95)
			return source_color.lerp(Color.WHITE, 0.22)


func _selection_overlay_material() -> StandardMaterial3D:
	if _room_selection_overlay == null:
		_room_selection_overlay = StandardMaterial3D.new()
		_room_selection_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_room_selection_overlay.albedo_color = Color(0.24, 0.5, 0.98, 0.16)
		_room_selection_overlay.emission_enabled = true
		_room_selection_overlay.emission = Color(0.28, 0.58, 1.0, 1.0)
		_room_selection_overlay.emission_energy_multiplier = 0.48
		_room_selection_overlay.roughness = 1.0
		_room_selection_overlay.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _room_selection_overlay


func _floor_pattern_texture(pattern_id: String, base_color: Color, line_color: Color) -> Texture2D:
	var cache_key := "%s|%s|%s" % [pattern_id, base_color.to_html(), line_color.to_html()]
	if _floor_pattern_texture_cache.has(cache_key):
		return _floor_pattern_texture_cache[cache_key] as Texture2D

	var size := 512
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(base_color)
	var line_width := 10

	match pattern_id:
		"rectangles":
			var tile_w := 248
			var tile_h := 154
			for y in range(0, size, tile_h):
				var row_offset := (tile_w / 2) if int(y / tile_h) % 2 == 1 else 0
				for x in range(-tile_w, size + tile_w, tile_w):
					image.fill_rect(Rect2i(x + row_offset, y, tile_w, line_width), line_color)
					image.fill_rect(Rect2i(x + row_offset, y, line_width, tile_h), line_color)
		"zigzag":
			var step := 132.0
			for y in range(size):
				for x in range(size):
					var diagonal_a := absf(fposmod(float(x + y), step) - step * 0.5)
					var diagonal_b := absf(fposmod(float(x - y) + step * 8.0, step) - step * 0.5)
					if diagonal_a <= line_width or diagonal_b <= line_width:
						image.set_pixel(x, y, line_color)
		"grid":
			var cell := 156
			for y in range(0, size, cell):
				image.fill_rect(Rect2i(0, y, size, line_width), line_color)
			for x in range(0, size, cell):
				image.fill_rect(Rect2i(x, 0, line_width, size), line_color)
		_:
			pass

	var texture := ImageTexture.create_from_image(image)
	_floor_pattern_texture_cache[cache_key] = texture
	return texture


func _floor_finish_material(finish_id: String) -> StandardMaterial3D:
	var finish := FLOOR_FINISHES.get(finish_id, FLOOR_FINISHES["oak_light"]) as Dictionary
	var base_material := finish.get("material", FLOOR_FINISHES["oak_light"]["material"]) as StandardMaterial3D
	var material := base_material.duplicate(true) as StandardMaterial3D
	var uv_scale := float(finish.get("uv_scale", 3.2))
	var use_world_triplanar := bool(finish.get("world_triplanar", false))
	var pattern_id := String(finish.get("pattern_id", ""))
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.set("texture_repeat", 1)
	material.uv1_scale = Vector3.ONE * uv_scale
	material.uv1_triplanar = use_world_triplanar
	material.uv1_world_triplanar = use_world_triplanar
	if finish.has("solid_color"):
		material.albedo_color = finish.get("solid_color") as Color
		material.albedo_texture = null
		material.normal_enabled = false
		material.ao_enabled = false
		material.uv1_triplanar = false
		material.uv1_world_triplanar = false
		material.roughness = 0.92
		return material
	if not pattern_id.is_empty():
		material.albedo_color = Color.WHITE
		material.albedo_texture = _floor_pattern_texture(
			pattern_id,
			finish.get("pattern_base_color", finish.get("swatch_color", Color(0.8, 0.8, 0.8))) as Color,
			finish.get("pattern_line_color", Color(0.7, 0.7, 0.7)) as Color
		)
		material.normal_enabled = false
		material.ao_enabled = false
		material.uv1_triplanar = false
		material.uv1_world_triplanar = false
	return material


func _render_room_finish(room_entry: Dictionary, finish_id: String) -> void:
	var floor_node := room_entry.get("floor_node", null) as MeshInstance3D
	if not is_instance_valid(floor_node):
		return
	if finish_id == "_room_default":
		var room_color := room_entry.get("display_color", Color(0.9, 0.9, 0.9)) as Color
		floor_node.material_override = _room_default_material(room_color)
	else:
		floor_node.material_override = _floor_finish_material(finish_id)
	_sync_focus_material_entry(floor_node)
	_refresh_wall_tints()
	_refresh_two_tone_shadow_for_room(
		String(room_entry.get("id", "")),
		_resolve_room_floor_color(room_entry, finish_id)
	)


func _resolve_room_floor_color(room_entry: Dictionary, finish_id: String) -> Color:
	if finish_id == "_room_default":
		return room_entry.get("display_color", Color(0.9, 0.9, 0.9)) as Color
	var finish := FLOOR_FINISHES.get(finish_id, {}) as Dictionary
	if finish.has("solid_color"):
		return finish.get("solid_color") as Color
	if finish.has("swatch_color"):
		return finish.get("swatch_color") as Color
	return room_entry.get("display_color", Color(0.9, 0.9, 0.9)) as Color


func _room_default_material(room_color: Color) -> StandardMaterial3D:
	var base_material := FLOOR_FINISHES["solid_neutral"]["material"] as StandardMaterial3D
	var material := base_material.duplicate(true) as StandardMaterial3D
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = room_color
	material.albedo_texture = null
	material.normal_enabled = false
	material.ao_enabled = false
	material.uv1_triplanar = false
	material.uv1_world_triplanar = false
	material.roughness = 0.92
	material.set_meta("pill_focus_solid_neutral", true)
	return material


func _default_finish_for_room(room_entry: Dictionary) -> String:
	if _active_home_skin_id == "solid_default":
		return "_room_default"
	var skin := HOME_SKINS.get(_active_home_skin_id, HOME_SKINS["warm_minimal"]) as Dictionary
	var mapping := skin.get("mapping", {}) as Dictionary
	return String(mapping.get(_home_skin_bucket_for_room(room_entry), "oak_light"))


func _home_skin_bucket_for_room(room_entry: Dictionary) -> String:
	var label := String(room_entry.get("label", ""))
	var category := String(room_entry.get("category", "ROOM"))
	if label == "Living":
		return "living"
	if label == "Kitchen":
		return "kitchen"
	if label.begins_with("Bath"):
		return "bath"
	if category == "BEDROOM":
		return "bedroom"
	if category == "CLOSET":
		return "accent"
	return "living"


func _make_wall_material(is_exterior: bool, tint: Color = Color(0.96, 0.96, 0.97)) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	if is_exterior:
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		material.albedo_color = EXTERIOR_WALL_COLOR
	else:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(tint.r, tint.g, tint.b, INTERIOR_WALL_ALPHA)
	material.roughness = 0.78
	material.clearcoat = 0.0
	material.cull_mode = BaseMaterial3D.CULL_BACK
	material.rim = 0.0
	material.set_meta("pill_focus_wall", true)
	material.set_meta("pill_focus_wall_exterior", is_exterior)
	return material


func _make_wall_material_dither(is_exterior: bool, tint: Color = Color(0.96, 0.96, 0.97)) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SHADER_WALL_MATERIAL_DITHER_UNLIT
	var base := EXTERIOR_WALL_COLOR if is_exterior else Color(tint.r, tint.g, tint.b, 1.0)
	material.set_shader_parameter("base_color", base)
	material.set_shader_parameter("accent_color", base.darkened(0.12))
	material.set_shader_parameter("accent_mix", 0.30)
	material.set_shader_parameter("tone_bias", 0.45)
	material.set_shader_parameter("vertical_gradient", 0.20)
	material.set_shader_parameter("ambient_darken", 0.15)
	material.set_shader_parameter("opacity", 0.55)
	material.set_shader_parameter("dither_mode", 1)
	material.set_meta("pill_focus_wall", true)
	material.set_meta("pill_focus_wall_exterior", is_exterior)
	return material


func _wall_tint_for_room_ids(room_ids: Array, is_exterior: bool) -> Color:
	var accum := Color(0.0, 0.0, 0.0, 0.0)
	var count := 0
	for room_id_raw in room_ids:
		var room_id := String(room_id_raw)
		if not _rooms_by_id.has(room_id):
			continue
		var room_entry := _rooms_by_id[room_id] as Dictionary
		var finish_id := String(room_entry.get("pending_finish_id", room_entry.get("finish_id", "")))
		var base := _floor_color_for_finish(finish_id, room_entry)
		accum.r += base.r
		accum.g += base.g
		accum.b += base.b
		count += 1
	if count == 0:
		return Color(0.96, 0.96, 0.97)
	var avg := Color(accum.r / count, accum.g / count, accum.b / count)
	# Soft, wall-friendly version of the floor hue: lighter + mildly desaturated.
	# Exterior walls pull toward white a bit more so the silhouette stays clean.
	var wash_t := WALL_TINT_WASH_EXTERIOR if is_exterior else WALL_TINT_WASH_INTERIOR
	return avg.lerp(WALL_TINT_HIGHLIGHT, wash_t)


func _floor_color_for_finish(finish_id: String, room_entry: Dictionary) -> Color:
	if FLOOR_FINISHES.has(finish_id):
		var finish := FLOOR_FINISHES[finish_id] as Dictionary
		if finish.has("solid_color"):
			return finish.get("solid_color") as Color
		if finish.has("pattern_base_color"):
			return finish.get("pattern_base_color") as Color
		if finish.has("swatch_color"):
			return finish.get("swatch_color") as Color
	return room_entry.get("display_color", Color(0.9, 0.9, 0.9)) as Color


func _refresh_wall_tints() -> void:
	for entry in _wall_tint_entries:
		var mesh := entry.get("mesh", null) as MeshInstance3D
		if not is_instance_valid(mesh):
			continue
		var is_exterior := bool(entry.get("is_exterior", false))
		if is_exterior:
			continue
		var room_ids: Array = entry.get("room_ids", []) as Array
		var tint := _wall_tint_for_room_ids(room_ids, is_exterior)
		var mat := mesh.material_override as StandardMaterial3D
		if mat == null:
			mat = _make_wall_material(is_exterior, tint)
			mesh.material_override = mat
		else:
			mat.albedo_color = Color(tint.r, tint.g, tint.b, INTERIOR_WALL_ALPHA)
		_sync_focus_material_entry(mesh)


func _build_contact_shadow(local_aabb: AABB, room_color: Color, model_id: String, is_preview: bool = false) -> Node3D:
	var root := Node3D.new()
	var footprint := _model_shadow_footprints.get(model_id, Vector2(CONTACT_SHADOW_SCALE, CONTACT_SHADOW_SCALE)) as Vector2
	var base_size := Vector2(
		maxf(local_aabb.size.x * footprint.x, CONTACT_SHADOW_MIN_SIZE.x),
		maxf(local_aabb.size.z * footprint.y, CONTACT_SHADOW_MIN_SIZE.y)
	)
	var alpha_multiplier := 0.6 if is_preview else 1.0
	var shadow_center := Vector3(local_aabb.get_center().x, 0.00045, local_aabb.get_center().z)
	var wide_color := room_color.darkened(0.46).lerp(Color(0.1, 0.12, 0.15, 1.0), 0.14)
	wide_color.a = CONTACT_SHADOW_ALPHA * alpha_multiplier
	root.add_child(_make_contact_shadow_plane(base_size, shadow_center, wide_color, 6))

	var core_color := room_color.darkened(0.64).lerp(Color.BLACK, 0.18)
	core_color.a = CONTACT_SHADOW_ALPHA * 0.78 * alpha_multiplier
	root.add_child(_make_contact_shadow_plane(base_size / CONTACT_SHADOW_CORE_SCALE, shadow_center + Vector3(0.0, 0.00015, 0.0), core_color, 7))

	if String(_model_kinds.get(model_id, "")) == MODEL_KIND_STEP_STOOL:
		var contact_color := room_color.darkened(0.72).lerp(Color.BLACK, 0.22)
		contact_color.a = CONTACT_SHADOW_ALPHA * 0.92 * alpha_multiplier
		root.add_child(
			_make_contact_shadow_plane(
				base_size / 2.7,
				shadow_center + Vector3(0.0, 0.00005, 0.0),
				contact_color,
				8
			)
		)
	return root


func _make_contact_shadow_plane(size: Vector2, center: Vector3, color: Color, render_priority: int) -> MeshInstance3D:
	var shadow := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	shadow.mesh = mesh
	shadow.position = center
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = _get_contact_shadow_texture()
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.render_priority = render_priority
	shadow.material_override = material
	return shadow


func _get_contact_shadow_texture() -> Texture2D:
	if _contact_shadow_texture == null:
		_contact_shadow_texture = _create_contact_shadow_texture()
	return _contact_shadow_texture


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


func _build_floor_label_decal(text: String, room_color: Color) -> Node3D:
	var root := Node3D.new()
	var viewport := SubViewport.new()
	viewport.disable_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var text_width := maxi(320, text.length() * 68)
	viewport.size = Vector2i(text_width, 144)
	root.add_child(viewport)

	var label := Label.new()
	label.text = text
	label.position = Vector2.ZERO
	label.size = viewport.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 62)
	label.add_theme_color_override("font_color", Color(0.44, 0.45, 0.48, 0.9))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.0))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	viewport.add_child(label)

	var decal := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	var width := clampf(text.length() * 0.22, 0.88, 2.7)
	plane.size = Vector2(width, 0.38)
	decal.mesh = plane
	decal.position = Vector3(0.0, 0.0, 0.0)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = viewport.get_texture()
	material.albedo_color = Color(1.0, 1.0, 1.0, 0.72)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.render_priority = 12
	decal.material_override = material
	root.add_child(decal)

	return root


func _apply_two_tone_shadow_to_furniture(root: Node3D, room_color: Color, is_preview: bool = false) -> void:
	if not is_instance_valid(root):
		return
	var body_overlay: Node = null
	if root.has_meta("furniture_body_overlay"):
		body_overlay = root.get_meta("furniture_body_overlay") as Node
	var floor_color := room_color
	floor_color.a = 1.0
	for mesh_instance in _collect_mesh_instances(root):
		if mesh_instance == body_overlay:
			continue
		var material := ShaderMaterial.new()
		material.shader = SHADER_FURNITURE_TWO_TONE_SHADOW
		material.set_shader_parameter("floor_color", floor_color)
		# Light angle is biased so the side facing the camera reads as the
		# clear lit face and the opposite side reads as the deeper shadow.
		material.set_shader_parameter("light_direction", Vector3(-0.50, 0.85, 0.55))
		# Softer terminator + secondary cues so cushion seams, pillow tops,
		# and rounded corners come through without going back to washed-out.
		# Tuned to the SmartThings VI reference. Three-tone structure:
		#   - cushion tops sit at ~floor colour (top_tone_white small, so
		#     tops don't bleach to white)
		#   - body lit sits ~14% darker than the floor (body_darken)
		#   - body shadow drops a further ~42% from there
		# This keeps cushion definition readable on any floor finish — even
		# near-white floors — without losing the "same family as the floor"
		# look. Softness 0.22 = clear cushion-seam lines but still soft.
		material.set_shader_parameter("body_darken", 0.14)
		material.set_shader_parameter("shadow_strength", 0.42)
		material.set_shader_parameter("highlight_strength", 0.04)
		material.set_shader_parameter("shadow_softness", 0.22)
		material.set_shader_parameter("top_lift", 0.65)
		material.set_shader_parameter("top_tone_white", 0.10)
		material.set_shader_parameter("top_lift_falloff", 0.50)
		material.set_shader_parameter("rim_strength", 0.06)
		material.set_shader_parameter("rim_power", 2.8)
		material.set_shader_parameter("ground_shadow_lift", 0.14)
		material.set_shader_parameter("alpha", 0.62 if is_preview else 1.0)
		material.set_shader_parameter("alpha_clip", 0.05)
		mesh_instance.material_override = material
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _refresh_two_tone_shadow_for_room(room_id: String, room_color: Color) -> void:
	if room_id.is_empty():
		return
	for root in _furniture_roots:
		if not is_instance_valid(root):
			continue
		if String(root.get_meta("furniture_room_id", "")) != room_id:
			continue
		var is_preview := bool(root.get_meta("furniture_is_preview", false))
		root.set_meta("furniture_room_color", room_color)
		_apply_two_tone_shadow_to_furniture(root, room_color, is_preview)


func _style_furniture_node(node: Node, room_color: Color, is_preview: bool = false, state: String = "normal") -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_instance.transparency = 0.62 if is_preview else FURNITURE_TRANSPARENCY
		# Only layer the brightening/selection-tint overlay for selection
		# states. In normal state, leave the two-tone shadow shader output
		# untouched so the silhouette stays crisp.
		var keeps_overlay := state == "selected" or state == "invalid_selected" or state == "preview_invalid"
		if keeps_overlay:
			mesh_instance.material_overlay = _make_furniture_overlay(room_color, is_preview, state)
		else:
			mesh_instance.material_overlay = null
	for child in node.get_children():
		_style_furniture_node(child, room_color, is_preview, state)


func _make_furniture_overlay(room_color: Color, is_preview: bool = false, state: String = "normal") -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var tint := room_color.lerp(Color.WHITE, 0.32)
	var alpha := 0.18 if is_preview else 0.08
	match state:
		"selected":
			tint = FURNITURE_SELECTION_COLOR
			alpha = 0.3
		"invalid_selected", "preview_invalid":
			tint = FURNITURE_INVALID_COLOR
			alpha = 0.3 if is_preview else 0.24
		"preview":
			alpha = 0.18
	material.albedo_color = Color(tint.r, tint.g, tint.b, alpha)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 1.0
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _apply_furniture_visual_state(root: Node3D, state: String) -> void:
	if not is_instance_valid(root):
		return
	if String(root.get_meta("furniture_visual_state", "")) == state:
		return
	root.set_meta("furniture_visual_state", state)
	var room_color := root.get_meta("furniture_room_color", Color(0.84, 0.86, 0.92)) as Color
	var is_preview := bool(root.get_meta("furniture_is_preview", false))
	var model := root.get_meta("furniture_model_node", null) as Node3D
	if is_instance_valid(model):
		_style_furniture_node(model, room_color, is_preview, state)
	var body_overlay := root.get_meta("furniture_body_overlay", null) as MeshInstance3D
	if is_instance_valid(body_overlay):
		_set_furniture_body_overlay_state(body_overlay, state)
	var gizmo := root.get_meta("furniture_selection_gizmo", null) as Node3D
	if is_instance_valid(gizmo):
		var show_gizmo := state == "selected" or state == "invalid_selected"
		gizmo.visible = show_gizmo
		if show_gizmo:
			_set_selection_gizmo_invalid(gizmo, state == "invalid_selected")


func _set_furniture_body_overlay_state(overlay: MeshInstance3D, state: String) -> void:
	overlay.visible = state == "selected" or state == "invalid_selected"
	if not overlay.visible:
		return
	var is_invalid := state == "invalid_selected"
	overlay.material_override = _furniture_body_overlay_material(
		FURNITURE_INVALID_COLOR if is_invalid else FURNITURE_SELECTION_COLOR,
		0.22 if is_invalid else 0.18,
		0.08 if is_invalid else 0.05
	)


func _set_selection_gizmo_invalid(gizmo: Node3D, is_invalid: bool) -> void:
	for child in gizmo.get_children():
		if child is MeshInstance3D:
			var mesh_instance := child as MeshInstance3D
			var handle_kind := String(mesh_instance.get_meta("selection_handle_kind", ""))
			if handle_kind.is_empty():
				if bool(mesh_instance.get_meta("selection_axis_line", false)):
					mesh_instance.material_override = _selection_axis_material(is_invalid)
				else:
					mesh_instance.material_override = _selection_gizmo_material(is_invalid)
			else:
				mesh_instance.material_override = _selection_handle_material(handle_kind, is_invalid)


func _collect_node_aabb(node: Node) -> AABB:
	var combined := AABB()
	var initialized := false
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		if mesh != null:
			combined = (node as MeshInstance3D).transform * mesh.get_aabb()
			initialized = true
	for child in node.get_children():
		var child_aabb := _collect_node_aabb(child)
		if child_aabb.size != Vector3.ZERO:
			if child is Node3D:
				child_aabb = (child as Node3D).transform * child_aabb
			if not initialized:
				combined = child_aabb
				initialized = true
			else:
				combined = combined.merge(child_aabb)
	return combined if initialized else AABB()


func _is_visible(properties: Variant) -> bool:
	if properties is Dictionary:
		return bool((properties as Dictionary).get("visible", true))
	return true


func _is_placement_active() -> bool:
	return not _placement_model_id.is_empty()


func _is_furniture_edit_active() -> bool:
	return _furniture_edit_mode and not _edit_mode


func _set_furniture_selection(model_id: String) -> void:
	if not model_id.is_empty():
		_clear_furniture_selection()
	_placement_model_id = model_id
	_placement_touch_index = -1
	_placement_mouse_pressed = false
	_placement_mouse_drag_distance = 0.0
	_placement_drag_active = false
	_placement_preview_rotation_y = 0.0
	_placement_preview_room_id = ""
	_placement_last_screen_position = Vector2.INF
	if _placement_model_id.is_empty():
		_clear_furniture_preview()
		_clear_android_furniture_catalog_selection()
		return
	_rebuild_furniture_preview(Color(0.82, 0.86, 0.92))


func _clear_furniture_preview() -> void:
	if is_instance_valid(_placement_preview_root):
		_placement_preview_root.queue_free()
	_placement_preview_root = null
	_placement_preview_room_id = ""
	_placement_last_screen_position = Vector2.INF


func _clear_furniture_selection() -> void:
	if is_instance_valid(_selected_furniture_root):
		_apply_furniture_visual_state(_selected_furniture_root, "normal")
	_selected_furniture_root = null
	_selected_furniture_touch_index = -1
	_selected_furniture_mouse_pressed = false
	_selected_furniture_interaction = ""
	_selected_furniture_drag_active = false
	_selected_furniture_last_valid_surface = {}
	_selected_furniture_last_valid_scale_factor = 1.0
	_selected_furniture_resize_start_scale_factor = 1.0
	_selected_furniture_resize_start_distance = 0.0


func _set_selected_furniture(root: Node3D) -> void:
	if not is_instance_valid(root):
		_clear_furniture_selection()
		return
	if _selected_furniture_root == root:
		_apply_furniture_visual_state(root, "selected")
		return
	_clear_furniture_selection()
	_selected_furniture_root = root
	_selected_furniture_last_valid_surface = _current_furniture_surface(root)
	_selected_furniture_last_valid_scale_factor = _current_furniture_scale_factor(root)
	_apply_furniture_visual_state(root, "selected")


func _current_furniture_scale_factor(root: Node3D) -> float:
	if not is_instance_valid(root):
		return 1.0
	return float(root.get_meta("furniture_scale_factor", 1.0))


func _current_furniture_surface(root: Node3D) -> Dictionary:
	if not is_instance_valid(root):
		return {}
	var point := Vector2(root.position.x, root.position.z)
	var room_entry := _find_room_entry(point)
	if room_entry.is_empty():
		room_entry = _rooms_by_id.get(String(root.get_meta("furniture_room_id", "")), {}) as Dictionary
	return {
		"point": point,
		"floor_y": root.position.y,
		"room": room_entry,
		"room_id": String(root.get_meta("furniture_room_id", "")),
		"color": root.get_meta("furniture_room_color", Color(0.84, 0.86, 0.92)),
		"valid": true,
		"requested_invalid": false,
		"scale_factor": _current_furniture_scale_factor(root),
	}


func _furniture_world_polygon(root: Node3D, collision := false) -> PackedVector2Array:
	if not is_instance_valid(root):
		return PackedVector2Array()
	var meta_key := "furniture_collision_footprint_local" if collision else "furniture_footprint_local"
	var local_polygon := root.get_meta(meta_key, PackedVector2Array()) as PackedVector2Array
	return _transform_footprint_polygon(
		local_polygon,
		Vector2(root.position.x, root.position.z),
		root.rotation_degrees.y
	)


func _furniture_center_2d(root: Node3D) -> Vector2:
	return Vector2(root.position.x, root.position.z)


func _furniture_handle_screen_point(root: Node3D, meta_name: String) -> Vector2:
	if not is_instance_valid(root):
		return Vector2.INF
	if not is_instance_valid(_camera):
		return Vector2.INF
	var local_point := root.get_meta(meta_name, Vector3.INF) as Vector3
	if local_point == Vector3.INF:
		return Vector2.INF
	var world_point := root.to_global(local_point)
	return _camera.unproject_position(world_point)


func _furniture_rotate_handle_screen_point(root: Node3D) -> Vector2:
	return _furniture_handle_screen_point(root, "furniture_rotate_handle_local")


func _furniture_resize_handle_screen_point(root: Node3D) -> Vector2:
	return _furniture_handle_screen_point(root, "furniture_resize_handle_local")


func _furniture_delete_handle_screen_point(root: Node3D) -> Vector2:
	return _furniture_handle_screen_point(root, "furniture_delete_handle_local")


func _find_furniture_root_at_point(point_2d: Vector2) -> Node3D:
	var nearest_root: Node3D
	var nearest_distance := INF
	for root in _furniture_roots:
		if not is_instance_valid(root):
			continue
		var polygon := _furniture_world_polygon(root)
		if polygon.size() < 3:
			continue
		var is_inside := Geometry2D.is_point_in_polygon(point_2d, polygon)
		var edge_distance := _distance_to_polygon(point_2d, polygon)
		if not is_inside and edge_distance > FURNITURE_TAP_EDGE_PADDING:
			continue
		var distance := point_2d.distance_to(_furniture_center_2d(root))
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_root = root
	return nearest_root


func _selected_furniture_handle_contains(screen_position: Vector2) -> bool:
	if not is_instance_valid(_selected_furniture_root):
		return false
	var handle_point := _furniture_rotate_handle_screen_point(_selected_furniture_root)
	if handle_point == Vector2.INF:
		return false
	return handle_point.distance_to(screen_position) <= FURNITURE_HANDLE_TAP_RADIUS


func _selected_furniture_resize_handle_contains(screen_position: Vector2) -> bool:
	if not is_instance_valid(_selected_furniture_root):
		return false
	var handle_point := _furniture_resize_handle_screen_point(_selected_furniture_root)
	if handle_point == Vector2.INF:
		return false
	return handle_point.distance_to(screen_position) <= FURNITURE_HANDLE_TAP_RADIUS


func _selected_furniture_delete_handle_contains(screen_position: Vector2) -> bool:
	if not is_instance_valid(_selected_furniture_root):
		return false
	var handle_point := _furniture_delete_handle_screen_point(_selected_furniture_root)
	if handle_point == Vector2.INF:
		return false
	return handle_point.distance_to(screen_position) <= FURNITURE_HANDLE_TAP_RADIUS


func _update_furniture_room_meta(root: Node3D, surface: Dictionary) -> void:
	if not is_instance_valid(root) or surface.is_empty():
		return
	root.position.y = float(surface.get("floor_y", FLOOR_SURFACE_Y))
	root.set_meta("furniture_room_id", String(surface.get("room_id", "")))
	root.set_meta("furniture_room_color", surface.get("color", Color(0.84, 0.86, 0.92)))


func _quantize_scale_factor(scale_factor: float) -> float:
	return clampf(
		round(scale_factor / FURNITURE_SCALE_STEP) * FURNITURE_SCALE_STEP,
		FURNITURE_SCALE_MIN,
		FURNITURE_SCALE_MAX
	)


func _revert_selected_furniture_to_last_valid() -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	_apply_furniture_scale_factor(_selected_furniture_root, _selected_furniture_last_valid_scale_factor)
	if not _selected_furniture_last_valid_surface.is_empty():
		var point := _selected_furniture_last_valid_surface.get(
			"point",
			_furniture_center_2d(_selected_furniture_root)
		) as Vector2
		_selected_furniture_root.position.x = point.x
		_selected_furniture_root.position.z = point.y
		_update_furniture_room_meta(_selected_furniture_root, _selected_furniture_last_valid_surface)


func _update_selected_furniture_drag(screen_position: Vector2) -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	var model_id := String(_selected_furniture_root.get_meta("furniture_model_id", ""))
	var scale_factor := _current_furniture_scale_factor(_selected_furniture_root)
	var surface := _surface_for_screen(
		screen_position,
		model_id,
		_selected_furniture_root.rotation_degrees.y,
		_selected_furniture_root,
		scale_factor
	)
	if surface.is_empty():
		if not _selected_furniture_last_valid_surface.is_empty():
			var fallback_point := _selected_furniture_last_valid_surface.get("point", _furniture_center_2d(_selected_furniture_root)) as Vector2
			_selected_furniture_root.position.x = fallback_point.x
			_selected_furniture_root.position.z = fallback_point.y
		_apply_furniture_visual_state(_selected_furniture_root, "invalid_selected")
		return

	var valid := bool(surface.get("valid", false))
	var point := surface.get("point", _furniture_center_2d(_selected_furniture_root)) as Vector2
	if valid:
		_selected_furniture_root.position.x = point.x
		_selected_furniture_root.position.z = point.y
		_update_furniture_room_meta(_selected_furniture_root, surface)
		_selected_furniture_last_valid_surface = surface
		_selected_furniture_last_valid_scale_factor = scale_factor
	else:
		_selected_furniture_root.position.x = point.x
		_selected_furniture_root.position.z = point.y
	_apply_furniture_visual_state(
		_selected_furniture_root,
		"invalid_selected" if bool(surface.get("requested_invalid", false)) or not valid else "selected"
	)


func _commit_selected_furniture_drag(screen_position: Vector2) -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	_update_selected_furniture_drag(screen_position)
	_revert_selected_furniture_to_last_valid()
	_apply_furniture_visual_state(_selected_furniture_root, "selected")


func _update_selected_furniture_resize(screen_position: Vector2) -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	var floor_point := _screen_to_floor(screen_position)
	if floor_point == Vector2.INF:
		_apply_furniture_visual_state(_selected_furniture_root, "invalid_selected")
		return
	var center := _furniture_center_2d(_selected_furniture_root)
	var current_distance := maxf(center.distance_to(floor_point), 0.001)
	var target_scale := _quantize_scale_factor(
		_selected_furniture_resize_start_scale_factor
		* (current_distance / maxf(_selected_furniture_resize_start_distance, 0.001))
	)
	var applied_scale := _apply_furniture_scale_factor(_selected_furniture_root, target_scale)
	var model_id := String(_selected_furniture_root.get_meta("furniture_model_id", ""))
	var surface := _surface_for_point(
		center,
		model_id,
		_selected_furniture_root.rotation_degrees.y,
		_selected_furniture_root,
		applied_scale
	)
	if surface.is_empty():
		_apply_furniture_visual_state(_selected_furniture_root, "invalid_selected")
		return
	var valid := bool(surface.get("valid", false))
	var point := surface.get("point", center) as Vector2
	_selected_furniture_root.position.x = point.x
	_selected_furniture_root.position.z = point.y
	if valid:
		_update_furniture_room_meta(_selected_furniture_root, surface)
		_selected_furniture_last_valid_surface = surface
		_selected_furniture_last_valid_scale_factor = applied_scale
	_apply_furniture_visual_state(
		_selected_furniture_root,
		"invalid_selected" if bool(surface.get("requested_invalid", false)) or not valid else "selected"
	)


func _commit_selected_furniture_resize(screen_position: Vector2) -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	_update_selected_furniture_resize(screen_position)
	if String(_selected_furniture_root.get_meta("furniture_visual_state", "")) == "invalid_selected":
		_revert_selected_furniture_to_last_valid()
	_apply_furniture_visual_state(_selected_furniture_root, "selected")


func _delete_selected_furniture() -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	var root := _selected_furniture_root
	_clear_furniture_selection()
	_furniture_roots.erase(root)
	root.queue_free()


func _step_selected_furniture_scale(direction := 1) -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	var current_scale := _current_furniture_scale_factor(_selected_furniture_root)
	var target_scale := current_scale + float(direction) * FURNITURE_SCALE_STEP
	if target_scale > FURNITURE_SCALE_MAX + 0.001:
		target_scale = FURNITURE_SCALE_MIN
	elif target_scale < FURNITURE_SCALE_MIN - 0.001:
		target_scale = FURNITURE_SCALE_MAX
	var applied_scale := _apply_furniture_scale_factor(_selected_furniture_root, target_scale)
	var model_id := String(_selected_furniture_root.get_meta("furniture_model_id", ""))
	var surface := _surface_for_point(
		_furniture_center_2d(_selected_furniture_root),
		model_id,
		_selected_furniture_root.rotation_degrees.y,
		_selected_furniture_root,
		applied_scale
	)
	if surface.is_empty() or not bool(surface.get("valid", false)):
		_revert_selected_furniture_to_last_valid()
		_apply_furniture_visual_state(_selected_furniture_root, "invalid_selected")
		_apply_furniture_visual_state(_selected_furniture_root, "selected")
		return
	var point := surface.get("point", _furniture_center_2d(_selected_furniture_root)) as Vector2
	_selected_furniture_root.position.x = point.x
	_selected_furniture_root.position.z = point.y
	_update_furniture_room_meta(_selected_furniture_root, surface)
	_selected_furniture_last_valid_surface = surface
	_selected_furniture_last_valid_scale_factor = applied_scale
	_apply_furniture_visual_state(_selected_furniture_root, "selected")


func _rotate_selected_furniture() -> void:
	if not is_instance_valid(_selected_furniture_root):
		return
	var next_rotation := wrapf(_selected_furniture_root.rotation_degrees.y + 90.0, 0.0, 360.0)
	var model_id := String(_selected_furniture_root.get_meta("furniture_model_id", ""))
	var scale_factor := _current_furniture_scale_factor(_selected_furniture_root)
	var surface := _surface_for_point(
		_furniture_center_2d(_selected_furniture_root),
		model_id,
		next_rotation,
		_selected_furniture_root,
		scale_factor
	)
	if surface.is_empty() or not bool(surface.get("valid", false)):
		_apply_furniture_visual_state(_selected_furniture_root, "invalid_selected")
		return
	_selected_furniture_root.rotation_degrees.y = next_rotation
	var point := surface.get("point", _furniture_center_2d(_selected_furniture_root)) as Vector2
	_selected_furniture_root.position.x = point.x
	_selected_furniture_root.position.z = point.y
	_update_furniture_room_meta(_selected_furniture_root, surface)
	_selected_furniture_last_valid_surface = surface
	_selected_furniture_last_valid_scale_factor = scale_factor
	_apply_furniture_visual_state(_selected_furniture_root, "selected")


func _rebuild_furniture_preview(room_color: Color) -> void:
	_clear_furniture_preview()
	if _placement_model_id.is_empty():
		return
	var preview = _create_furniture_root(
		_placement_model_id,
		Vector2.ZERO,
		_sample_floor_height(Vector2.ZERO),
		_placement_preview_rotation_y,
		room_color,
		true,
	)
	if preview == null:
		return
	_placement_preview_root = preview
	_placement_preview_root.visible = false
	_home_pivot.add_child(_placement_preview_root)


func _surface_for_point(
	position_2d: Vector2,
	model_id: String = "",
	rotation_y: float = 0.0,
	ignored_root: Node3D = null,
	scale_factor := 1.0,
) -> Dictionary:
	var room_entry := _find_room_entry(position_2d)
	var placement_point := position_2d
	if room_entry.is_empty():
		var snapped_surface := _snap_point_to_nearest_room(position_2d)
		room_entry = snapped_surface.get("room", {}) as Dictionary
		if room_entry.is_empty():
			return {}
		placement_point = snapped_surface.get("point", position_2d) as Vector2
	var valid := true
	var requested_invalid := false
	var overlap_requested := false
	if not model_id.is_empty():
		var plan := _plan_furniture_position(
			placement_point,
			room_entry,
			model_id,
			rotation_y,
			ignored_root,
			scale_factor
		)
		if plan.is_empty():
			return {}
		placement_point = plan.get("point", placement_point) as Vector2
		valid = bool(plan.get("valid", false))
		requested_invalid = bool(plan.get("requested_invalid", false))
		overlap_requested = bool(plan.get("overlap_requested", false))
	return {
		"point": placement_point,
		"floor_y": _sample_floor_height(placement_point),
		"room": room_entry,
		"room_id": String(room_entry.get("id", "")),
		"color": room_entry.get("display_color", Color(0.84, 0.86, 0.92)),
		"valid": valid,
		"requested_invalid": requested_invalid,
		"overlap_requested": overlap_requested,
	}


func _snap_point_to_nearest_room(position_2d: Vector2) -> Dictionary:
	var nearest_point := Vector2.INF
	var nearest_room := {}
	var nearest_distance := FURNITURE_ROOM_EDGE_SNAP_DISTANCE

	for room_entry in _room_entries:
		var polygon := room_entry.get("polygon", PackedVector2Array()) as PackedVector2Array
		if polygon.size() < 3:
			continue
		var centroid := room_entry.get("centroid", Vector2.ZERO) as Vector2
		var segment_count := polygon.size()
		for index in range(segment_count):
			var start := polygon[index]
			var end := polygon[(index + 1) % segment_count]
			var candidate_point := Geometry2D.get_closest_point_to_segment(position_2d, start, end)
			var distance := candidate_point.distance_to(position_2d)
			if distance >= nearest_distance:
				continue
			var inset_direction := centroid - candidate_point
			if inset_direction.length() <= 0.0001:
				inset_direction = Vector2.UP
			inset_direction = inset_direction.normalized() * FURNITURE_ROOM_SNAP_INSET
			var snapped_point := candidate_point + inset_direction
			if not _point_on_or_in_room_polygon(snapped_point, room_entry):
				snapped_point = candidate_point - inset_direction
			if _point_on_or_in_room_polygon(snapped_point, room_entry):
				nearest_distance = distance
				nearest_point = snapped_point
				nearest_room = room_entry

	if nearest_room.is_empty() or nearest_point == Vector2.INF:
		return {}

	return {
		"room": nearest_room,
		"point": nearest_point,
	}


func _point_on_or_in_room_polygon(point_2d: Vector2, room_entry: Dictionary) -> bool:
	var polygon := room_entry.get("polygon", PackedVector2Array()) as PackedVector2Array
	if polygon.size() < 3:
		return false
	if Geometry2D.is_point_in_polygon(point_2d, polygon):
		return true
	return _distance_to_polygon(point_2d, polygon) <= FURNITURE_ROOM_EDGE_EPSILON


func _distance_to_polygon(point_2d: Vector2, polygon: PackedVector2Array) -> float:
	var min_distance := INF
	var point_count := polygon.size()
	if point_count < 3:
		return INF
	for index in range(point_count):
		var segment_start := polygon[index]
		var segment_end := polygon[(index + 1) % point_count]
		var segment_point := Geometry2D.get_closest_point_to_segment(point_2d, segment_start, segment_end)
		min_distance = min(min_distance, point_2d.distance_to(segment_point))
	return min_distance


func _surface_for_screen(
	screen_position: Vector2,
	model_id: String = "",
	rotation_y: float = 0.0,
	ignored_root: Node3D = null,
	scale_factor := 1.0,
) -> Dictionary:
	var floor_point := _screen_to_floor(screen_position)
	if floor_point == Vector2.INF:
		return {}
	return _surface_for_point(floor_point, model_id, rotation_y, ignored_root, scale_factor)


func _update_furniture_preview(screen_position: Vector2) -> void:
	if not _is_placement_active():
		return
	_placement_last_screen_position = screen_position
	var surface := _surface_for_screen(screen_position, _placement_model_id, _placement_preview_rotation_y)
	if surface.is_empty():
		if is_instance_valid(_placement_preview_root):
			_placement_preview_root.visible = false
		return

	var room_id := String(surface.get("room_id", ""))
	var room_color := surface.get("color", Color(0.84, 0.86, 0.92)) as Color
	if not is_instance_valid(_placement_preview_root) or _placement_preview_room_id != room_id:
		_rebuild_furniture_preview(room_color)
		_placement_preview_room_id = room_id
	if not is_instance_valid(_placement_preview_root):
		return

	var point := surface.get("point", Vector2.ZERO) as Vector2
	_placement_preview_root.visible = true
	_placement_preview_root.position = Vector3(point.x, float(surface.get("floor_y", FLOOR_SURFACE_Y)), point.y)
	_placement_preview_root.rotation_degrees.y = _placement_preview_rotation_y
	_apply_furniture_visual_state(
		_placement_preview_root,
		"preview_invalid" if bool(surface.get("requested_invalid", false)) or not bool(surface.get("valid", false)) else "preview"
	)


func _commit_furniture_placement(screen_position: Vector2) -> void:
	if not _is_placement_active():
		return
	var surface := _surface_for_screen(screen_position, _placement_model_id, _placement_preview_rotation_y)
	if surface.is_empty() or not bool(surface.get("valid", false)):
		return
	var point := surface.get("point", Vector2.ZERO) as Vector2
	var now := Time.get_ticks_msec()
	if now - _last_furniture_commit_time_msec <= FURNITURE_DUPLICATE_COMMIT_WINDOW_MS \
		and _last_furniture_commit_point != Vector2.INF \
		and _last_furniture_commit_point.distance_to(point) <= FURNITURE_GRID_STEP * 0.5:
		return
	var room_color := surface.get("color", Color(0.84, 0.86, 0.92)) as Color
	var floor_y := float(surface.get("floor_y", FLOOR_SURFACE_Y))
	var room_id := String(surface.get("room_id", ""))
	var added_root := _add_furniture_instance(_placement_model_id, point, _placement_preview_rotation_y, room_color, room_id)
	if is_instance_valid(added_root):
		_last_furniture_commit_time_msec = now
		_last_furniture_commit_point = point
		_spawn_furniture_drop_fx(point, floor_y, true)
		_set_furniture_selection("")
		if _is_furniture_edit_active():
			_set_selected_furniture(added_root)


func _spawn_furniture_drop_fx(position_2d: Vector2, floor_y: float, dramatic := false) -> void:
	var packed_scene := DUST_PUFF_DRAMATIC_SCENE if dramatic else DUST_PUFF_SCENE
	var dust_variant := packed_scene.instantiate()
	if dust_variant == null:
		return
	if not dust_variant is Node3D:
		if dust_variant is Node:
			dust_variant.queue_free()
		return
	var dust := dust_variant as Node3D
	dust.position = Vector3(position_2d.x, floor_y + 0.02, position_2d.y)
	_home_pivot.add_child(dust)


func _format_category(category: String) -> String:
	var parts := category.split("_")
	var formatted := []
	for part in parts:
		if part.is_empty():
			continue
		formatted.append(part.substr(0, 1).to_upper() + part.substr(1).to_lower())
	return " ".join(formatted) if not formatted.is_empty() else "Room"


func _apply_zoom_scale(next_scale: float, allow_zoom_out_overscroll := false) -> void:
	if _edit_mode:
		_set_zoom_scale_immediate(1.0)
		_apply_camera_zoom_for_view_mode()
		return
	var clamped_scale := _clamped_zoom_scale(next_scale)
	_zoom_rest_scale = clamped_scale
	if allow_zoom_out_overscroll:
		_zoom_scale = _softened_zoom_out_scale(next_scale, clamped_scale)
	else:
		_zoom_scale = clamped_scale
	_zoom_velocity = 0.0
	_apply_camera_zoom_for_view_mode()


func _current_pinch_distance() -> float:
	var pinch_vector := _current_pinch_vector()
	if pinch_vector == Vector2.ZERO:
		return 0.0
	return pinch_vector.length()


func _current_pinch_angle() -> float:
	var pinch_vector := _current_pinch_vector()
	if pinch_vector == Vector2.ZERO:
		return 0.0
	return atan2(pinch_vector.y, pinch_vector.x)


func _current_pinch_vector() -> Vector2:
	if _touch_points.size() < 2:
		return Vector2.ZERO
	var touch_indices: Array = _touch_points.keys()
	touch_indices.sort()
	var first_position := _touch_points[touch_indices[0]] as Vector2
	var second_position := _touch_points[touch_indices[1]] as Vector2
	return second_position - first_position


func _pan_floor_plan(from_screen: Vector2, to_screen: Vector2) -> void:
	var from_floor := _screen_to_floor(from_screen)
	var to_floor := _screen_to_floor(to_screen)
	if from_floor == Vector2.INF or to_floor == Vector2.INF:
		return
	var pan_delta := from_floor - to_floor
	if pan_delta.is_zero_approx():
		return
	_plan_focus = _clamp_plan_focus_local(
		Vector3(
			_plan_focus.x + pan_delta.x,
			PLAN_FOCUS_HEIGHT,
			_plan_focus.z + pan_delta.y
		)
	)
	_update_camera_for_viewport()


func _single_finger_pan_allowed() -> bool:
	if _edit_mode:
		return false
	return _zoom_rest_scale < (_current_zoom_max_scale() - ZOOMED_OUT_PAN_EPSILON)


func _handle_room_tap(screen_position: Vector2) -> void:
	if not _edit_mode and not _is_furniture_edit_active():
		var device_id := _find_device_pin_at_screen(screen_position)
		if not device_id.is_empty():
			if not _show_device_control_popup(device_id):
				_toggle_device_pin(device_id)
			_last_tap_time_ms = 0
			return
		_set_selected_air_quality_device("")
	if not _edit_mode and _is_3d_view:
		var now_ms: int = Time.get_ticks_msec()
		var elapsed: int = now_ms - _last_tap_time_ms
		var close_enough: bool = screen_position.distance_to(_last_tap_position) <= DOUBLE_TAP_MAX_DISTANCE_PX
		if _last_tap_time_ms > 0 and elapsed <= DOUBLE_TAP_MAX_MS and close_enough:
			_last_tap_time_ms = 0
			_zoom_to_full_view()
			return
		_last_tap_time_ms = now_ms
		_last_tap_position = screen_position
	var floor_point := _screen_to_floor(screen_position)
	if floor_point == Vector2.INF:
		return
	if _is_furniture_edit_active():
		if is_instance_valid(_selected_furniture_root):
			_clear_furniture_selection()
		return
	if not _edit_mode and is_instance_valid(_selected_furniture_root):
		_clear_furniture_selection()
		return
	var room_entry := _find_room_entry(floor_point)
	if room_entry.is_empty():
		if _edit_mode:
			_set_selected_room("")
		return
	if _edit_mode:
		var room_id := String(room_entry.get("id", ""))
		var selection_changed := room_id != _selected_room_id
		_set_selected_room(room_id)
		if selection_changed and _rooms_by_id.has(room_id):
			_begin_room_edit(_rooms_by_id[room_id] as Dictionary)
		return
	_zoom_to_room(room_entry)


func _screen_to_floor(screen_position: Vector2) -> Vector2:
	if not is_instance_valid(_camera):
		return Vector2.INF
	var ray_origin := _camera.project_ray_origin(screen_position)
	var ray_direction := _camera.project_ray_normal(screen_position)
	if abs(ray_direction.y) <= 0.0001:
		return Vector2.INF
	var distance := (FLOOR_SURFACE_Y - ray_origin.y) / ray_direction.y
	if distance < 0.0:
		return Vector2.INF
	var world_position := ray_origin + ray_direction * distance
	var local_position := _home_pivot.global_transform.affine_inverse() * world_position
	return Vector2(local_position.x, local_position.z)


func _zoom_to_room(room_entry: Dictionary) -> void:
	if not is_instance_valid(_camera):
		return
	var bounds := room_entry.get("bounds", Rect2(Vector2.ZERO, Vector2.ONE)) as Rect2
	var centroid := room_entry.get("centroid", Vector2.ZERO) as Vector2
	_plan_focus = Vector3(centroid.x, PLAN_FOCUS_HEIGHT, centroid.y)

	var target_scale: float
	if _is_3d_view:
		var room_max: float = maxf(bounds.size.x, bounds.size.y)
		var plan_max: float = maxf(_plan_size.x, _plan_size.y)
		target_scale = clampf(
			(room_max / maxf(plan_max, 0.001)) * ROOM_TAP_PADDING,
			_current_zoom_min_scale(),
			minf(0.82, _current_zoom_max_scale())
		)
	else:
		var viewport_size := get_viewport().get_visible_rect().size
		var aspect := viewport_size.x / maxf(viewport_size.y, 1.0)
		var desired_size := maxf(bounds.size.y, bounds.size.x / maxf(aspect, 0.01)) * ROOM_TAP_PADDING
		target_scale = clampf(
			desired_size / maxf(_base_camera_size, 0.001),
			_current_zoom_min_scale(),
			minf(0.82, _current_zoom_max_scale())
		)
	_set_zoom_scale_immediate(target_scale)
	_update_camera_for_viewport()


func _zoom_to_full_view() -> void:
	if not is_instance_valid(_camera):
		return
	_plan_focus = Vector3(0.0, PLAN_FOCUS_HEIGHT, 0.0)
	_set_zoom_scale_immediate(_current_zoom_max_scale())
	_update_camera_for_viewport()


func _visible_floor_bounds_local() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	var points := PackedVector2Array()
	for screen_point in [
		Vector2.ZERO,
		Vector2(viewport_size.x, 0.0),
		viewport_size,
		Vector2(0.0, viewport_size.y),
	]:
		var floor_point := _screen_to_floor(screen_point)
		if floor_point == Vector2.INF:
			return Rect2(Vector2.ZERO, Vector2.ZERO)
		points.append(floor_point)
	return _bounds_for_polygon(points)


func _clamp_plan_focus_local(next_focus: Vector3) -> Vector3:
	var clamped := next_focus
	clamped.y = PLAN_FOCUS_HEIGHT
	if _edit_mode or not is_instance_valid(_camera):
		return clamped
	var visible_bounds := _visible_floor_bounds_local()
	if visible_bounds.size.is_zero_approx():
		return clamped
	var plan_half := _plan_size * 0.5
	var plan_min := -plan_half
	var plan_max := plan_half
	var visible_max := visible_bounds.position + visible_bounds.size
	if visible_bounds.size.x >= _plan_size.x:
		clamped.x = 0.0
	else:
		var min_focus_x := _plan_focus.x + plan_min.x - visible_bounds.position.x
		var max_focus_x := _plan_focus.x + plan_max.x - visible_max.x
		clamped.x = clampf(next_focus.x, min_focus_x, max_focus_x)
	if visible_bounds.size.y >= _plan_size.y:
		clamped.z = 0.0
	else:
		var min_focus_z := _plan_focus.z + plan_min.y - visible_bounds.position.y
		var max_focus_z := _plan_focus.z + plan_max.y - visible_max.y
		clamped.z = clampf(next_focus.z, min_focus_z, max_focus_z)
	return clamped


func _plan_focus_world() -> Vector3:
	if not is_instance_valid(_home_pivot):
		return _plan_focus
	return _home_pivot.global_transform * _plan_focus


func _update_front_wall_cutaway() -> void:
	if _exterior_wall_records.is_empty() or not is_instance_valid(_camera) or not is_instance_valid(_home_pivot):
		return
	var inverse := _home_pivot.global_transform.affine_inverse()
	var cam_local: Vector3 = inverse * _camera.global_position
	var cam_xz := Vector2(cam_local.x, cam_local.z)
	if cam_xz.length() <= 0.0001:
		_reset_exterior_wall_transparency()
		return
	var cam_dir := cam_xz.normalized()
	var best_score := -INF
	for record in _exterior_wall_records:
		best_score = max(best_score, (record.get("outward", Vector2.ZERO) as Vector2).dot(cam_dir))
	var cutaway_threshold := maxf(best_score - 0.18, 0.55)
	for record in _exterior_wall_records:
		var mesh := record.get("mesh", null) as MeshInstance3D
		var box := record.get("box", null) as BoxMesh
		if not is_instance_valid(mesh) or box == null:
			continue
		var base_height := float(record.get("base_height", EXTERIOR_WALL_HEIGHT))
		var length := float(record.get("length", 1.0))
		var score := (record.get("outward", Vector2.ZERO) as Vector2).dot(cam_dir)
		var want_dither := score >= cutaway_threshold
		var target_mat: Material = record.get("mat_dither", null) if want_dither else record.get("mat_solid", null)
		if target_mat != null and mesh.material_override != target_mat:
			mesh.material_override = target_mat
		var height := FRONT_WALL_CUTAWAY_HEIGHT if want_dither else base_height
		box.size = Vector3(WALL_THICKNESS, height, length)
		mesh.position.y = height * 0.5


func _reset_exterior_wall_transparency() -> void:
	for record in _exterior_wall_records:
		var mesh := record.get("mesh", null) as MeshInstance3D
		var box := record.get("box", null) as BoxMesh
		if not is_instance_valid(mesh) or box == null:
			continue
		var solid: Material = record.get("mat_solid", null)
		if solid != null and mesh.material_override != solid:
			mesh.material_override = solid
		var base_height := float(record.get("base_height", EXTERIOR_WALL_HEIGHT))
		var length := float(record.get("length", 1.0))
		box.size = Vector3(WALL_THICKNESS, base_height, length)
		mesh.position.y = base_height * 0.5


func _set_home_rotation_y(rotation_y: float) -> void:
	if not is_instance_valid(_home_pivot):
		return
	_home_pivot.rotation_degrees.y = rotation_y
	if is_instance_valid(_camera):
		_update_camera_for_viewport()


func _rotate_to_quadrant(delta: int) -> void:
	_angle_index = posmod(_angle_index + delta, 8)
	if _is_3d_view and not _edit_mode:
		_plan_focus = Vector3(0.0, PLAN_FOCUS_HEIGHT, 0.0)
	var from_rotation := _home_pivot.rotation_degrees.y
	var target_rotation := BASE_PLAN_ROTATION_Y + ROTATE_SNAP_STEP_DEG * _angle_index
	var shortest: float = wrapf(target_rotation - from_rotation, -180.0, 180.0)
	target_rotation = from_rotation + shortest
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(Callable(self, "_set_home_rotation_y"), from_rotation, target_rotation, 0.32)


func _update_camera_for_viewport() -> void:
	if not is_instance_valid(_camera):
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var is_portrait := viewport_size.y > viewport_size.x
	var max_dimension := maxf(_plan_size.x, _plan_size.y) + PLATFORM_MARGIN * 4.2

	if _edit_mode:
		_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		_plan_focus = Vector3(0.0, PLAN_FOCUS_HEIGHT, 0.0)
		var edit_focus_world := _plan_focus_world()
		_camera.position = edit_focus_world + Vector3(0.0, max_dimension * 2.2, 0.0)
		_camera.look_at(edit_focus_world, Vector3.BACK)
		_base_camera_size = _required_ortho_size(viewport_size, 1.12)
		_reset_exterior_wall_transparency()
	elif _is_3d_view:
		var focus_world := _plan_focus_world()
		_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		var fov_deg := 65.0
		_camera.fov = fov_deg
		_base_camera_fov = fov_deg
		var pitch_rad := deg_to_rad(SMARTTHINGS_CAMERA_PITCH_DEG)
		var viewport_aspect: float = maxf(viewport_size.x / maxf(viewport_size.y, 1.0), 0.001)
		var plan_width: float = max_dimension * 1.0
		var plan_depth: float = max_dimension * 0.6
		var half_v := tan(deg_to_rad(fov_deg) * 0.5)
		var half_h := half_v * viewport_aspect
		var dist_for_width: float = (plan_width * 0.5) / maxf(half_h, 0.001)
		var projected_depth: float = plan_depth * cos(pitch_rad) + EXTERIOR_WALL_HEIGHT * sin(pitch_rad)
		var dist_for_depth: float = (projected_depth * 0.5) / maxf(half_v, 0.001)
		var fit_factor := 1.34 if is_portrait else 0.88
		var distance: float = maxf(dist_for_width, dist_for_depth) * fit_factor
		var cam_offset := Vector3(0.0, distance * sin(pitch_rad), distance * cos(pitch_rad))
		_camera.position = focus_world + cam_offset
		_camera.look_at(focus_world + Vector3(0.0, 0.1, 0.0), Vector3.UP)
		_update_front_wall_cutaway()
	else:
		var focus_world := _plan_focus_world()
		_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		_base_camera_fov = SOFT_2D_CAMERA_FOV
		if is_portrait:
			_camera.position = focus_world + Vector3(0.0, max_dimension * SOFT_2D_PORTRAIT_HEIGHT, SOFT_2D_LOOK_OFFSET_Z)
		else:
			_camera.position = focus_world + Vector3(0.0, max_dimension * SOFT_2D_LANDSCAPE_HEIGHT, SOFT_2D_LOOK_OFFSET_Z)
		_camera.look_at(focus_world + Vector3(0.0, SOFT_2D_FOCUS_LIFT, SOFT_2D_LOOK_OFFSET_Z), Vector3.BACK)
		_base_camera_size = _required_ortho_size(viewport_size, VIEW_PADDING_2D)
		_reset_exterior_wall_transparency()
	_apply_camera_zoom_for_view_mode()


func _apply_camera_zoom_for_view_mode() -> void:
	if not is_instance_valid(_camera):
		return
	if _camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		_camera.size = _base_camera_size * _zoom_scale
	else:
		_camera.fov = maxf(SOFT_2D_MIN_FOV, _base_camera_fov * _zoom_scale)
	_update_device_pin_zoom_scale()


func _update_device_pin_zoom_scale() -> void:
	for device_id in _device_pin_order:
		var device := _device_pins.get(device_id, {}) as Dictionary
		var pin: Variant = _device_pin_instance(device)
		if pin != null and pin is Node3D:
			_apply_device_pin_zoom_scale(pin as Node3D)


func _apply_device_pin_zoom_scale(pin: Node3D) -> void:
	pin.scale = Vector3.ONE * DEVICE_PIN_BASE_SCALE * _device_pin_zoom_compensation_scale()


func _device_pin_zoom_compensation_scale() -> float:
	if _edit_mode:
		return 1.0
	var zoom_in_progress := clampf((1.0 - _zoom_scale) / DEVICE_PIN_ZOOM_COMPENSATION_RANGE, 0.0, 1.0)
	var eased_zoom_in_progress := smoothstep(0.0, 1.0, zoom_in_progress)
	return lerpf(1.0, DEVICE_PIN_ZOOM_MIN_VISUAL_SCALE, eased_zoom_in_progress)


func _current_zoom_min_scale() -> float:
	if _edit_mode:
		return 1.0
	if _is_3d_view:
		return ZOOM_3D_MIN_SCALE
	return SOFT_2D_MIN_FOV / maxf(_base_camera_fov, 0.001)


func _current_zoom_max_scale() -> float:
	if _edit_mode:
		return 1.0
	if _is_3d_view:
		return ZOOM_3D_MAX_SCALE
	return SOFT_2D_MAX_FOV / maxf(_base_camera_fov, 0.001)


func _clamped_zoom_scale(next_scale: float) -> float:
	return clampf(next_scale, _current_zoom_min_scale(), _current_zoom_max_scale())


func _softened_zoom_out_scale(next_scale: float, clamped_scale: float) -> float:
	if next_scale <= clamped_scale:
		return clamped_scale
	var zoom_range := maxf(_current_zoom_max_scale() - _current_zoom_min_scale(), 0.001)
	var overscroll_limit := zoom_range * ZOOM_OUT_OVERSCROLL_RANGE_FRACTION
	if overscroll_limit <= 0.0:
		return clamped_scale
	var overscroll := next_scale - clamped_scale
	var softened_overscroll := overscroll_limit * (1.0 - 1.0 / ((overscroll / overscroll_limit) + 1.0))
	return clamped_scale + softened_overscroll


func _set_zoom_scale_immediate(next_scale: float) -> void:
	_zoom_scale = _clamped_zoom_scale(next_scale)
	_zoom_rest_scale = _zoom_scale
	_zoom_velocity = 0.0


func _begin_pinch_gesture() -> void:
	_pinch_active = true
	_suppress_single_touch_until_release = true
	_pinch_distance = _current_pinch_distance()
	_pinch_start_zoom_scale = _zoom_scale
	_pinch_angle = _current_pinch_angle()
	_pinch_rotation_accum = 0.0
	_zoom_velocity = 0.0
	if _is_3d_view and not _edit_mode:
		_plan_focus = Vector3(0.0, PLAN_FOCUS_HEIGHT, 0.0)


func _finish_pinch_gesture() -> void:
	_pinch_active = false
	_pinch_distance = 0.0
	_pinch_start_zoom_scale = _zoom_scale
	_pinch_angle = 0.0
	_pinch_rotation_accum = 0.0
	_zoom_rest_scale = _clamped_zoom_scale(_zoom_rest_scale)
	if is_instance_valid(_home_pivot) and _is_3d_view and not _edit_mode:
		var current_deg: float = _home_pivot.rotation_degrees.y
		var snapped: float = roundf(current_deg / ROTATE_SNAP_STEP_DEG) * ROTATE_SNAP_STEP_DEG
		_home_pivot.rotation_degrees.y = snapped
		_angle_index = posmod(int(round((snapped - BASE_PLAN_ROTATION_Y) / ROTATE_SNAP_STEP_DEG)), 8)
		_update_camera_for_viewport()


func _update_zoom_spring(delta: float) -> void:
	if _edit_mode:
		if not is_equal_approx(_zoom_scale, 1.0) or not is_equal_approx(_zoom_rest_scale, 1.0):
			_zoom_scale = 1.0
			_zoom_rest_scale = 1.0
			_zoom_velocity = 0.0
			_apply_camera_zoom_for_view_mode()
		return
	if _pinch_active:
		return
	var displacement := _zoom_rest_scale - _zoom_scale
	if absf(displacement) <= ZOOM_SPRING_SNAP_DISTANCE and absf(_zoom_velocity) <= ZOOM_SPRING_SNAP_SPEED:
		if not is_equal_approx(_zoom_scale, _zoom_rest_scale):
			_zoom_scale = _zoom_rest_scale
			_zoom_velocity = 0.0
			_apply_camera_zoom_for_view_mode()
		return
	_zoom_velocity += displacement * ZOOM_SPRING_STIFFNESS * delta
	_zoom_velocity *= exp(-ZOOM_SPRING_DAMPING * delta)
	_zoom_scale += _zoom_velocity * delta
	_apply_camera_zoom_for_view_mode()


func _required_ortho_size(viewport_size: Vector2, padding: float) -> float:
	var aspect := viewport_size.x / maxf(viewport_size.y, 1.0)
	if aspect <= 0.0:
		return maxf(_plan_size.x, _plan_size.y)

	var inverse_camera := _camera.global_transform.affine_inverse()
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	for world_point in _plan_world_corners():
		var local_point := inverse_camera * world_point
		min_x = min(min_x, local_point.x)
		max_x = max(max_x, local_point.x)
		min_y = min(min_y, local_point.y)
		max_y = max(max_y, local_point.y)

	var span_x := max_x - min_x
	var span_y := max_y - min_y
	return maxf(span_y, span_x / aspect) * padding


func _plan_world_corners() -> Array[Vector3]:
	var corners: Array[Vector3] = []
	var half_x := (_plan_size.x + PLATFORM_MARGIN * 1.2) * 0.5
	var half_z := (_plan_size.y + PLATFORM_MARGIN * 1.2) * 0.5
	var min_y := -PLATFORM_HEIGHT
	var max_y := EXTERIOR_WALL_HEIGHT + 0.18
	for x in [-half_x, half_x]:
		for z in [-half_z, half_z]:
			corners.append(_home_pivot.global_transform * Vector3(x, min_y, z))
			corners.append(_home_pivot.global_transform * Vector3(x, max_y, z))
	return corners


func _set_camera_focus_active(is_active: bool) -> void:
	if _camera_focus_active == is_active:
		return
	_camera_focus_active = is_active
	_apply_greyscale(is_active)
	_clear_all_camera_callouts()
	_last_single_camera_device_id = ""
	_ensure_camera_overlay_layer()
	_camera_overlay_layer.visible = is_active
	if is_active:
		for device_id in _device_pin_order:
			var device := _device_pins.get(device_id, {}) as Dictionary
			if String(device.get("kind", "")) != DEVICE_KIND_CAMERA:
				continue
			_ensure_camera_callout_for_device(device_id)
			_notify_camera_callout_java(device_id)


func _ensure_camera_overlay_layer() -> void:
	if _camera_overlay_layer != null and is_instance_valid(_camera_overlay_layer):
		return
	_camera_overlay_layer = CanvasLayer.new()
	_camera_overlay_layer.layer = 10
	_camera_overlay_layer.visible = false
	add_child(_camera_overlay_layer)


func _update_camera_callout_positions() -> void:
	if _camera_callout_nodes.is_empty():
		return
	if _camera == null or not is_instance_valid(_camera):
		return
	var viewport := get_viewport()
	var viewport_size := viewport.get_visible_rect().size if viewport != null else Vector2.ZERO
	for device_id in _camera_callout_nodes.keys():
		var entry_variant: Variant = _camera_callout_nodes[device_id]
		if not entry_variant is Dictionary:
			continue
		var entry := entry_variant as Dictionary
		var container_variant: Variant = entry.get("container", null)
		if not container_variant is Control or not is_instance_valid(container_variant as Control):
			continue
		var container := container_variant as Control
		var device := _device_pins.get(device_id, {}) as Dictionary
		var pin: Variant = _device_pin_instance(device)
		if pin == null or not is_instance_valid(pin as Node3D):
			container.visible = false
			continue
		var pin_world := (pin as Node3D).global_position
		var tip_world := pin_world + Vector3(0.0, CAMERA_CALLOUT_ANCHOR_Y, 0.0)
		if _camera.is_position_behind(tip_world):
			container.visible = false
			continue
		var screen_pos := _camera.unproject_position(tip_world)
		var tip_local: Vector2 = entry.get("pointer_tip_local", Vector2.ZERO)
		var top_left := screen_pos - tip_local
		if viewport_size != Vector2.ZERO:
			top_left.x = clamp(top_left.x, 8.0, max(8.0, viewport_size.x - container.size.x - 8.0))
			top_left.y = max(8.0, top_left.y)
		container.position = top_left
		container.visible = true


func _set_energy_focus_active(is_active: bool) -> void:
	if _energy_focus_active == is_active:
		return
	_energy_focus_active = is_active
	_energy_focus_token += 1
	_clear_all_energy_callouts()
	if is_active:
		_start_energy_focus_reveal(_energy_focus_token)


func _start_energy_focus_reveal(token: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var ids := _device_pin_order.duplicate()
	if ids.is_empty():
		return
	for i in ids.size():
		var j := rng.randi_range(0, ids.size() - 1)
		var tmp = ids[i]
		ids[i] = ids[j]
		ids[j] = tmp
	var bulk_index := rng.randi_range(0, ids.size() - 1)
	var per_device := {}
	var total_kwh := 0.0
	var savings_kwh := 0.0
	for i in ids.size():
		var id_str: String = ids[i]
		var kwh := rng.randf_range(0.8, 4.0)
		if i == bulk_index:
			kwh = rng.randf_range(55.0, 75.0)
		var is_savings := rng.randf() < 0.2
		per_device[id_str] = {"kwh": kwh, "is_savings": is_savings}
		total_kwh += kwh
		if is_savings:
			savings_kwh += kwh
	for i in ids.size():
		if token != _energy_focus_token or not _energy_focus_active:
			return
		var id_str: String = ids[i]
		var entry := per_device[id_str] as Dictionary
		_ensure_energy_callout_for_device(id_str, float(entry["kwh"]), bool(entry["is_savings"]))
		await get_tree().create_timer(rng.randf_range(ENERGY_CALLOUT_STAGGER_MIN, ENERGY_CALLOUT_STAGGER_MAX)).timeout
	if token != _energy_focus_token or not _energy_focus_active:
		return
	var usage_cost := total_kwh * 0.081
	var savings_cost := savings_kwh * 0.495
	var saving_rate := 0.0
	if total_kwh > 0.0:
		saving_rate = clamp((savings_kwh / total_kwh) * 100.0, 0.0, 100.0)
	_notify_energy_summary(saving_rate, total_kwh, usage_cost, savings_kwh, savings_cost)


func _apply_greyscale(enable: bool) -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	env.adjustment_enabled = enable
	if enable:
		env.adjustment_saturation = 0.0
	else:
		env.adjustment_saturation = 1.0


func _show_single_camera_callout(device_id: String) -> void:
	if _camera_focus_active:
		return
	if _last_single_camera_device_id == device_id and _camera_callout_nodes.has(device_id):
		_clear_all_camera_callouts()
		_last_single_camera_device_id = ""
		return
	_clear_all_camera_callouts()
	_ensure_camera_callout_for_device(device_id)
	_last_single_camera_device_id = device_id
	_notify_camera_callout_java(device_id)


func _ensure_camera_callout_for_device(device_id: String) -> void:
	_ensure_camera_overlay_layer()
	if _camera_overlay_layer != null and not _camera_overlay_layer.visible:
		_camera_overlay_layer.visible = true
	var existing: Variant = _camera_callout_nodes.get(device_id, null)
	if existing != null and existing is Dictionary:
		var existing_container: Variant = (existing as Dictionary).get("container", null)
		if existing_container is Control and is_instance_valid(existing_container as Control):
			(existing_container as Control).visible = true
			return
		_camera_callout_nodes.erase(device_id)
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty():
		return
	var pin: Variant = _device_pin_instance(device)
	if pin == null or not pin is Node3D:
		return
	var image_path := String(device.get("image_path", ""))
	var tex := _load_camera_texture(image_path)
	if tex == null:
		return
	var image_w := CAMERA_CALLOUT_IMAGE_SIZE.x
	var image_h := CAMERA_CALLOUT_IMAGE_SIZE.y
	var pad := CAMERA_CALLOUT_PADDING
	var panel_w := image_w + pad * 2.0
	var panel_h := image_h + pad * 2.0
	var total_w := panel_w
	var total_h := panel_h + CAMERA_CALLOUT_POINTER_HEIGHT
	var container := Control.new()
	container.size = Vector2(total_w, total_h)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := PanelContainer.new()
	panel.position = Vector2(0.0, 0.0)
	panel.size = Vector2(panel_w, panel_h)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.07, 0.97)
	style.corner_radius_top_left = 36
	style.corner_radius_top_right = 36
	style.corner_radius_bottom_left = 36
	style.corner_radius_bottom_right = 36
	style.border_color = Color(0.16, 0.17, 0.19, 1.0)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = pad
	style.content_margin_right = pad
	style.content_margin_top = pad
	style.content_margin_bottom = pad
	panel.add_theme_stylebox_override("panel", style)
	container.add_child(panel)

	var image_mask := PanelContainer.new()
	image_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_mask.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var mask_style := StyleBoxFlat.new()
	mask_style.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	mask_style.corner_radius_top_left = 26
	mask_style.corner_radius_top_right = 26
	mask_style.corner_radius_bottom_left = 26
	mask_style.corner_radius_bottom_right = 26
	image_mask.add_theme_stylebox_override("panel", mask_style)
	panel.add_child(image_mask)

	var image_rect := TextureRect.new()
	image_rect.texture = tex
	image_rect.custom_minimum_size = CAMERA_CALLOUT_IMAGE_SIZE
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_mask.add_child(image_rect)

	var pointer := Polygon2D.new()
	var tip_x := total_w * 0.5
	var base_y := panel_h - 1.0
	var tip_y := panel_h + CAMERA_CALLOUT_POINTER_HEIGHT
	pointer.polygon = PackedVector2Array([
		Vector2(tip_x - CAMERA_CALLOUT_POINTER_HALF_BASE, base_y),
		Vector2(tip_x + CAMERA_CALLOUT_POINTER_HALF_BASE, base_y),
		Vector2(tip_x, tip_y),
	])
	pointer.color = Color(0.06, 0.06, 0.07, 0.97)
	container.add_child(pointer)

	_camera_overlay_layer.add_child(container)
	_camera_callout_nodes[device_id] = {
		"container": container,
		"pointer_tip_local": Vector2(tip_x, tip_y),
	}


func _load_camera_texture(image_path: String) -> Texture2D:
	if image_path.is_empty():
		return null
	if ResourceLoader.exists(image_path):
		var res_variant: Variant = load(image_path)
		if res_variant is Texture2D:
			return res_variant as Texture2D
	var file := FileAccess.open(image_path, FileAccess.READ)
	if file == null:
		return null
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var image := Image.new()
	var lower := image_path.to_lower()
	var err := ERR_FILE_UNRECOGNIZED
	if lower.ends_with(".jpg") or lower.ends_with(".jpeg"):
		err = image.load_jpg_from_buffer(bytes)
	elif lower.ends_with(".png"):
		err = image.load_png_from_buffer(bytes)
	elif lower.ends_with(".webp"):
		err = image.load_webp_from_buffer(bytes)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)


func _ensure_energy_callout_for_device(device_id: String, kwh: float, is_savings: bool) -> void:
	var existing: Variant = _energy_callout_nodes.get(device_id, null)
	if existing != null and existing is Node and is_instance_valid(existing as Node):
		(existing as Node).queue_free()
	_energy_callout_nodes.erase(device_id)
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty():
		return
	var pin: Variant = _device_pin_instance(device)
	if pin == null or not pin is Node3D:
		return
	var accent := Color(0.44, 0.89, 0.71) if is_savings else Color(0.41, 0.76, 1.0)
	var icon := _energy_callout_icon(is_savings)
	var text := "%.2f kWh" % kwh
	var wrapper := _build_bubble_callout(
		ENERGY_CALLOUT_VIEWPORT_SIZE,
		ENERGY_CALLOUT_BUBBLE_SIZE,
		ENERGY_CALLOUT_PIXEL_SIZE,
		ENERGY_CALLOUT_ANCHOR_Y,
		null,
		text,
		accent,
		ENERGY_CALLOUT_LABEL_FONT_SIZE,
		icon,
	)
	(pin as Node3D).add_child(wrapper)
	wrapper.scale = Vector3(0.6, 0.6, 0.6)
	var tween := create_tween()
	tween.tween_property(wrapper, "scale", Vector3.ONE, 0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_energy_callout_nodes[device_id] = wrapper


func _energy_callout_icon(is_savings: bool) -> Texture2D:
	if is_savings:
		if _energy_bolt_icon == null or not is_instance_valid(_energy_bolt_icon):
			if ResourceLoader.exists(ENERGY_CALLOUT_ICON_ENERGY_PATH):
				var tex: Variant = load(ENERGY_CALLOUT_ICON_ENERGY_PATH)
				if tex is Texture2D:
					_energy_bolt_icon = tex as Texture2D
		return _energy_bolt_icon
	if _energy_plug_icon == null or not is_instance_valid(_energy_plug_icon):
		if ResourceLoader.exists(ENERGY_CALLOUT_ICON_PLUG_PATH):
			var tex2: Variant = load(ENERGY_CALLOUT_ICON_PLUG_PATH)
			if tex2 is Texture2D:
				_energy_plug_icon = tex2 as Texture2D
	return _energy_plug_icon


func _build_bubble_callout(
	viewport_size: Vector2i,
	bubble_size: Vector2,
	pixel_size: float,
	anchor_y: float,
	image_texture: Texture2D,
	label_text: String,
	label_color: Color,
	label_font_size: int,
	icon_texture: Texture2D = null,
) -> Node3D:
	var wrapper := Node3D.new()
	var viewport := SubViewport.new()
	viewport.disable_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = viewport_size
	wrapper.add_child(viewport)

	var viewport_w := float(viewport_size.x)
	var viewport_h := float(viewport_size.y)
	var bubble_width := bubble_size.x
	var bubble_height := bubble_size.y
	var bubble_top := 10.0
	var bubble_left := (viewport_w - bubble_width) * 0.5
	var bubble_bottom := bubble_top + bubble_height
	var pointer_tip_y := viewport_h - 4.0
	var pointer_half_base := 16.0

	var canvas := Control.new()
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(canvas)

	var bubble := PanelContainer.new()
	bubble.position = Vector2(bubble_left, bubble_top)
	bubble.size = Vector2(bubble_width, bubble_height)
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.06, 0.07, 0.97)
	panel_style.corner_radius_top_left = 36
	panel_style.corner_radius_top_right = 36
	panel_style.corner_radius_bottom_left = 36
	panel_style.corner_radius_bottom_right = 36
	panel_style.border_color = Color(0.16, 0.17, 0.19, 1.0)
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 14
	panel_style.content_margin_bottom = 14
	bubble.add_theme_stylebox_override("panel", panel_style)
	canvas.add_child(bubble)

	var pointer := Polygon2D.new()
	pointer.polygon = PackedVector2Array([
		Vector2(viewport_w * 0.5 - pointer_half_base, bubble_bottom - 1.0),
		Vector2(viewport_w * 0.5 + pointer_half_base, bubble_bottom - 1.0),
		Vector2(viewport_w * 0.5, pointer_tip_y),
	])
	pointer.color = Color(0.06, 0.06, 0.07, 0.97)
	canvas.add_child(pointer)

	if image_texture != null:
		var image_rect := TextureRect.new()
		image_rect.texture = image_texture
		image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image_rect.clip_contents = true
		image_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		image_rect.custom_minimum_size = Vector2(bubble_width - 28.0, bubble_height - 28.0)
		bubble.add_child(image_rect)
	elif icon_texture != null:
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 14)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bubble.add_child(row)
		var icon_rect := TextureRect.new()
		icon_rect.texture = icon_texture
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.custom_minimum_size = Vector2(float(label_font_size) * 1.4, float(label_font_size) * 1.4)
		icon_rect.modulate = label_color
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon_rect)
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.text = label_text
		label.add_theme_font_size_override("font_size", label_font_size)
		label.add_theme_color_override("font_color", label_color)
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.35))
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 2)
		row.add_child(label)
	else:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.text = label_text
		label.add_theme_font_size_override("font_size", label_font_size)
		label.add_theme_color_override("font_color", label_color)
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.35))
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 2)
		bubble.add_child(label)

	var sprite := Sprite3D.new()
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.pixel_size = pixel_size
	sprite.no_depth_test = true
	sprite.shaded = false
	sprite.render_priority = 12
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var sprite_half_height := viewport_h * 0.5 * pixel_size
	sprite.position = Vector3(0.0, anchor_y + sprite_half_height, 0.0)
	wrapper.add_child(sprite)
	sprite.texture = viewport.get_texture()
	return wrapper


func _clear_all_camera_callouts() -> void:
	for id in _camera_callout_nodes.keys():
		var entry: Variant = _camera_callout_nodes[id]
		if entry is Dictionary:
			var container: Variant = (entry as Dictionary).get("container", null)
			if container is Node and is_instance_valid(container as Node):
				(container as Node).queue_free()
		elif entry is Node and is_instance_valid(entry as Node):
			(entry as Node).queue_free()
	_camera_callout_nodes.clear()


func _clear_all_energy_callouts() -> void:
	for id in _energy_callout_nodes.keys():
		var node: Variant = _energy_callout_nodes[id]
		if node is Node and is_instance_valid(node as Node):
			(node as Node).queue_free()
	_energy_callout_nodes.clear()


func _notify_camera_callout_java(device_id: String) -> void:
	var device := _device_pins.get(device_id, {}) as Dictionary
	if device.is_empty():
		return
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_SHOW_CAMERA_CALLOUT):
		return
	plugin.call(
		JAVA_METHOD_SHOW_CAMERA_CALLOUT,
		device_id,
		String(device.get("room_label", "Room")),
		String(device.get("image_asset", CAMERA_CALLOUT_ASSET_PATH))
	)


func _notify_energy_summary(
	saving_rate: float,
	usage_kwh: float,
	usage_cost: float,
	savings_kwh: float,
	savings_cost: float
) -> void:
	var plugin = _plugin_singleton()
	if plugin == null or not _plugin_has_java_method(plugin, JAVA_METHOD_NOTIFY_ENERGY_SUMMARY):
		return
	plugin.call(
		JAVA_METHOD_NOTIFY_ENERGY_SUMMARY,
		float(saving_rate),
		float(usage_kwh),
		float(usage_cost),
		float(savings_kwh),
		float(savings_cost)
	)
