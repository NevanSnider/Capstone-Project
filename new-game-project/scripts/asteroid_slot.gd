extends Control

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if GlobalSettings.golden_asteroids > 0:
				GlobalSettings.golden_asteroids -= 1
