extends Panel

signal task_accepted(task_id: String)
signal quest_dialog_requested(quest_id: String)

var task_id: String = ""
var is_quest: bool = false

@onready var title_label = $VBoxContainer/TitleLabel
@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var requirements_label = $VBoxContainer/RequirementsLabel
@onready var reward_label = $VBoxContainer/RewardLabel
@onready var accept_button = $VBoxContainer/AcceptButton

func _ready():
	custom_minimum_size = Vector2(280, 0)
	accept_button.pressed.connect(_on_accept_button_pressed)

func setup_task(task):
	task_id = task.id
	title_label.text = task.title
	
	var req_text = "Requires: "
	var req_parts = []
	for requirement in task.requirements:
		var amount = task.requirements[requirement]
		var item_name = requirement.replace("_", " ").capitalize()
		req_parts.append("%d %s" % [amount, item_name])
	requirements_label.text = req_text + ", ".join(req_parts)
	
	var reward_parts = []
	for resource in task.rewards:
		var amount = task.rewards[resource]
		var resource_name = resource.capitalize()
		reward_parts.append("%d %s" % [amount, resource_name])
	reward_label.text = "Reward: " + ", ".join(reward_parts)
	
	description_label.text = task.description

func setup_quest(quest):
	task_id = quest.id
	is_quest = true
	title_label.text = quest.title
	
	description_label.visible = false
	reward_label.visible = false
	
	var req_text = "Objective: "
	var req_parts = []
	for requirement in quest.requirements:
		var amount = quest.requirements[requirement]
		var item_name = requirement.replace("_", " ").capitalize()
		req_parts.append("%d %s" % [amount, item_name])
	requirements_label.text = req_text + ", ".join(req_parts)
	
	accept_button.text = "Talk to The Boss"

func _on_accept_button_pressed():
	if is_quest:
		quest_dialog_requested.emit(task_id)
	else:
		task_accepted.emit(task_id)
	queue_free()
