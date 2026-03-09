extends Panel

signal task_accepted(task_id: String)

var task_id: String = ""

@onready var title_label = $VBoxContainer/TitleLabel
@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var requirements_label = $VBoxContainer/RequirementsLabel
@onready var reward_label = $VBoxContainer/RewardLabel
@onready var accept_button = $VBoxContainer/AcceptButton

func _ready():
	custom_minimum_size = Vector2(0, 150)
	accept_button.pressed.connect(_on_accept_button_pressed)

func setup_task(task: TaskManager.Task):
	task_id = task.id
	title_label.text = task.title
	description_label.text = task.description
	
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

func _on_accept_button_pressed():
	task_accepted.emit(task_id)
	queue_free()
