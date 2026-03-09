extends Node

signal task_accepted(task_id: String)
signal task_completed(task_id: String)
signal tasks_updated

class Task:
	var id: String
	var title: String
	var description: String
	var rewards: Dictionary
	var requirements: Dictionary
	var is_active: bool = false
	var is_completed: bool = false
	
	func _init(_id: String, _title: String, _desc: String, _rewards: Dictionary, _requirements: Dictionary):
		id = _id
		title = _title
		description = _desc
		rewards = _rewards
		requirements = _requirements

var available_tasks: Array[Task] = []
var active_tasks: Array[Task] = []
var completed_tasks: Array[Task] = []

func _ready():
	create_initial_tasks()
	GlobalSettings.inventory_changed.connect(_on_inventory_changed)

func create_initial_tasks():
	available_tasks.append(Task.new(
		"test_asteroid",
		"First Collection",
		"Collect 1 golden asteroid",
		{"gold": 100},
		{"golden_asteroids": 1}
	))
	
	available_tasks.append(Task.new(
		"collect_asteroids_1",
		"Asteroid Collector",
		"Collect 5 golden asteroids",
		{"gold": 300, "cobalt": 100},
		{"golden_asteroids": 5}
	))
	
	available_tasks.append(Task.new(
		"collect_packages_1",
		"Package Delivery",
		"Collect the package",
		{"gold": 1000, "titanium": 500},
		{"packages": 1}
	))

func accept_task(task_id: String):
	for i in range(available_tasks.size()):
		if available_tasks[i].id == task_id:
			var task = available_tasks[i]
			task.is_active = true
			active_tasks.append(task)
			available_tasks.remove_at(i)
			task_accepted.emit(task_id)
			tasks_updated.emit()
			print("TASK ACCEPTED: ", task.title)
			print("Requirements: ", format_requirements(task))
			return

func _on_inventory_changed():
	auto_complete_tasks()

func auto_complete_tasks():
	var i = 0
	while i < active_tasks.size():
		var task = active_tasks[i]
		if check_task_completion(task):
			print("COMPLETED TASK: ", task.title)
			complete_task_internal(task)
		else:
			i += 1

func check_task_completion(task: Task) -> bool:
	for requirement in task.requirements:
		var required_amount = task.requirements[requirement]
		var current_amount = 0
		
		match requirement:
			"golden_asteroids":
				current_amount = GlobalSettings.golden_asteroids
			"packages":
				current_amount = GlobalSettings.packages
		
		if current_amount < required_amount:
			return false
	
	return true

func complete_task_internal(task: Task):
	for requirement in task.requirements:
		var required_amount = task.requirements[requirement]
		match requirement:
			"golden_asteroids":
				GlobalSettings.golden_asteroids -= required_amount
			"packages":
				GlobalSettings.packages -= required_amount
	
	var ship = get_node_or_null("/root/Game/Ship")
	if ship:
		for resource in task.rewards:
			var amount = task.rewards[resource]
			match resource:
				"gold":
					ship.add_money(amount)
				"cobalt":
					ship.add_cobalt(amount)
				"titanium":
					ship.add_titanium(amount)
				"copper":
					ship.add_copper(amount)
				"iron":
					ship.add_iron(amount)
	else:
		print("WARNING: Could not find Ship to give rewards!")
	
	task.is_completed = true
	completed_tasks.append(task)
	
	for i in range(active_tasks.size()):
		if active_tasks[i].id == task.id:
			active_tasks.remove_at(i)
			break
	
	task_completed.emit(task.id)
	tasks_updated.emit()
	
	print("TASK COMPLETED: ", task.title)
	print("Rewards Given: ", format_rewards(task))

func get_task_progress(task: Task) -> String:
	var progress_parts = []
	
	for requirement in task.requirements:
		var required_amount = task.requirements[requirement]
		var current_amount = 0
		
		match requirement:
			"golden_asteroids":
				current_amount = GlobalSettings.golden_asteroids
			"packages":
				current_amount = GlobalSettings.packages
		
		var item_name = requirement.replace("_", " ").capitalize()
		progress_parts.append("%s: %d/%d" % [item_name, current_amount, required_amount])
	
	return " | ".join(progress_parts)

func format_requirements(task: Task) -> String:
	var parts = []
	for requirement in task.requirements:
		var amount = task.requirements[requirement]
		var item_name = requirement.replace("_", " ").capitalize()
		parts.append("%d %s" % [amount, item_name])
	return ", ".join(parts)

func format_rewards(task: Task) -> String:
	var parts = []
	for resource in task.rewards:
		var amount = task.rewards[resource]
		var resource_name = resource.capitalize()
		parts.append("%d %s" % [amount, resource_name])
	return ", ".join(parts)
