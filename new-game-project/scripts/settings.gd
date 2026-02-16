extends Node2D

@onready var camera_lock_toggle = $Control/LockCamera
@onready var ez_mode_toggle = $Control/EZMode
@onready var accessibility_toggle = $Control/AccessibilityMode

func _ready():
	if camera_lock_toggle:
		camera_lock_toggle.button_pressed = GlobalSettings.camera_lock
			
	if ez_mode_toggle:
		ez_mode_toggle.button_pressed = GlobalSettings.ez_mode
		
	if accessibility_toggle:
		accessibility_toggle.button_pressed = GlobalSettings.accessibility_mode

func _on_cameralock_toggled(toggled_on: bool) -> void:
	GlobalSettings.camera_lock = toggled_on
	GlobalSettings.save_settings()

func _on_ezmode_toggled(toggled_on: bool) -> void:
	GlobalSettings.ez_mode = toggled_on
	GlobalSettings.save_settings()
	
func _on_accessibility_mode_toggled(toggled_on: bool) -> void:
	GlobalSettings.accessibility_mode = toggled_on
	GlobalSettings.save_settings()

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
