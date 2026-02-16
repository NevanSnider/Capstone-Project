#Code Artifact Name: Shop Script
#Description: The code handles the opening and closing of the shop
#Programmer's name: Nevan Snider
#Date created: 2/14/2026
#Date modified: 2/14/2026
#Preconditions: You take an input from the base whether the player is in it or not
#Postconditions: Changes the visibility of the shop and pauses/unpauses the game
#Error and exceptions: N/A
#Side effects: N/A
#Invariants: N/A
#Any known faults: N/A

extends Control

var player_in_base = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
#sets the player as either in the base or not
func set_pib(value: bool):
	player_in_base = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#The base can be opened if the player is in the shop, and will close when F is pressed a second time
func _input(event):
	if event.is_action_pressed("open_shop"):
		if visible:
			toggle()
		elif player_in_base:
			toggle()

#helper function that toggles the visibility of the menu and pauses the game while its visible
func toggle():
	visible = !visible
	get_tree().paused = visible
