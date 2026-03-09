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

@onready var task_container = $TaskScrollContainer/TaskContainer
var player_in_base = false
var task_card_scene = preload("res://scenes/task_card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	populate_tasks()
	TaskManager.tasks_updated.connect(populate_tasks)
	
func populate_tasks():
	#clear existing tasks cards
	for child in task_container.get_children():
		child.queue_free()
	
	#add card for each available task
	for task in TaskManager.available_tasks:
		var card = task_card_scene.instantiate()
		task_container.add_child(card)
		card.setup_task(task)
		card.task_accepted.connect(_on_task_accepted)

func _on_task_accepted(task_id: String):
	TaskManager.accept_task(task_id)
	print("Task accepted from shop: ", task_id)

	
	for task in TaskManager.active_tasks:
		if TaskManager.check_task_completion(task):
			print("Completing task: ", task.title)
			TaskManager.complete_task(task.id, "/root/Game/Ship")

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
