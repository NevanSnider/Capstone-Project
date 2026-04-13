extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer = 25
	update_save_slot_displays()
	

func update_save_slot_displays():
	for slot in [1, 2, 3]:
		var save_info = SaveManager.get_save_info(slot)
		var button = get_node("Background/Control/Slot" + str(slot) + "Button")
		
		if save_info.get("exists", false):
			button.text = "Overwrite Save " + str(slot) + "\n" + save_info.get("date", "Unknown")
		else:
			button.text = "Save to Slot " + str(slot)

func _on_slot_1_button_pressed():
	if SaveManager.save_game_to_slot(1):
		print("Saved to Slot 1!")
		GlobalSettings.current_save_slot = 1
		close_menu()

func _on_slot_2_button_pressed():
	if SaveManager.save_game_to_slot(2):
		print("Saved to Slot 2!")
		GlobalSettings.current_save_slot = 2
		close_menu()

func _on_slot_3_button_pressed():
	if SaveManager.save_game_to_slot(3):
		print("Saved to Slot 3!")
		GlobalSettings.current_save_slot = 3
		close_menu()

func close_menu():
	get_tree().paused = false
	queue_free()

func _on_return_pressed():
	get_tree().paused = false
	queue_free()
