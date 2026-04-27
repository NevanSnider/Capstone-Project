extends CanvasLayer

signal quest_accepted(quest_id: String)

var current_quest_id: String = ""

func _ready():
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var accept_button = get_node_or_null("Panel/VBoxContainer/HBoxContainer/AcceptButton")
	if accept_button:
		accept_button.pressed.connect(_on_accept_button_pressed)

func show_quest(quest):
	current_quest_id = quest.id
	$Panel/VBoxContainer/LoreLabel.text = quest.quest_lore
	show()

func _on_accept_button_pressed():
	quest_accepted.emit(current_quest_id)
	queue_free()
