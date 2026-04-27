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
var quest_dialog_scene = preload("res://scenes/quest_dialog.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if task_container:
		populate_tasks()
		TaskManager.tasks_updated.connect(populate_tasks)
	
func populate_tasks():
	if not task_container:
		return
		
	#clear existing tasks cards
	for child in task_container.get_children():
		child.queue_free()
	
	#add card for each available task
	for quest in TaskManager.available_quests:
		if quest.is_locked:
			continue
		var card = task_card_scene.instantiate()
		task_container.add_child(card)
		card.setup_quest(quest)
		card.quest_dialog_requested.connect(_on_quest_dialog_requested)
	
	for task in TaskManager.available_tasks:
		var card = task_card_scene.instantiate()
		task_container.add_child(card)
		card.setup_task(task)
		card.task_accepted.connect(_on_task_accepted)

func _on_task_accepted(task_id: String):
	TaskManager.accept_task(task_id)

func _on_quest_dialog_requested(quest_id: String):
	var quest = null
	for q in TaskManager.available_quests:
		if q.id == quest_id:
			quest = q
			break
	if quest:
		var dialog = quest_dialog_scene.instantiate()
		get_tree().root.add_child(dialog)
		dialog.show_quest(quest)
		dialog.quest_accepted.connect(func(id): TaskManager.accept_quest(id))

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
