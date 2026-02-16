extends Node2D

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_check_button_toggled(toggled_on: bool) -> void:
	AccessibilityHandler.isAccessibilityEnabled = toggled_on
