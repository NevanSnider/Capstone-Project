# Script for load save from main menu
extends Node2D

func _ready():
	update_save_slot_displays()

func update_save_slot_displays():
	for slot in [1, 2, 3]:
		var save_info = SaveManager.get_save_info(slot)
		var button = get_node("Background/Control/Slot" + str(slot) + "Button")
		
		if save_info.get("exists", false):
			button.text = "Load Save " + str(slot) + "\n" + save_info.get("date", "Unknown")
			button.disabled = false
		else:
			button.text = "Empty Slot"
			button.disabled = true

func _on_slot_1_button_pressed():
	print("BUTTON 1 PRESSED")
	load_slot(1)

func _on_slot_2_button_pressed():
	print("BUTTON 2 PRESSED")
	load_slot(2)

func _on_slot_3_button_pressed():
	print("BUTTON 3 PRESSED")
	load_slot(3)

func load_slot(slot: int):
	var save_data = SaveManager.load_game_from_slot(slot)
	if not save_data.is_empty():
		GlobalSettings.current_save_slot = slot
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_return_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
