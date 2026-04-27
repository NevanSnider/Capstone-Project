extends Node

signal task_accepted(task_id: String)
signal task_completed(task_id: String)
signal quest_accepted(quest_id: String)
signal quest_completed(quest_id: String)
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

class Quest:
	var id: String
	var title: String
	var quest_lore: String = ""
	var requirements: Dictionary
	var is_active: bool = false
	var is_completed: bool = false
	var is_locked: bool = false
	var unlock_after: String = ""
	
	func _init(_id: String, _title: String, _quest_lore: String, _requirements: Dictionary, _unlock_after: String = ""):
		id = _id
		title = _title
		quest_lore = _quest_lore
		requirements = _requirements
		unlock_after = _unlock_after
		is_locked = (unlock_after != "")

var available_tasks: Array[Task] = []
var active_tasks: Array[Task] = []
var completed_tasks: Array[Task] = []

var available_quests: Array[Quest] = []
var active_quests: Array[Quest] = []
var completed_quests: Array[Quest] = []

func _ready():
	if available_tasks.is_empty() and active_tasks.is_empty() and completed_tasks.is_empty():
		create_initial_tasks()
	
	if available_quests.is_empty() and active_quests.is_empty() and completed_quests.is_empty():
		create_initial_quests()
	
	GlobalSettings.inventory_changed.connect(_on_inventory_changed)

func create_initial_tasks():
	available_tasks.append(Task.new(
		"test_asteroid",
		"First Collection",
		"Collect 1 golden asteroid",
		{"gold": 50},
		{"golden_asteroids": 1}
	))
	
	available_tasks.append(Task.new(
		"collect_asteroids_1",
		"Asteroid Collector",
		"Collect 5 golden asteroids",
		{"gold": 300, "cobalt": 50},
		{"golden_asteroids": 5}
	))
	
	available_tasks.append(Task.new(
		"mixed_collection",
		"Mixed Haul",
		"Collect 3 asteroids and 2 packages",
		{"gold": 500, "cobalt": 100, "iron": 50},
		{"golden_asteroids": 3, "packages": 2}
	))

func create_initial_quests():
	available_quests.append(Quest.new(
		"quest_1",
		"Quest 1: First Delivery",
		"Hey, rookie! Welcome to Home Base, I will assign you your first mission. Go pick up that super important package and return it to me, pronto! I'll mark it on your minimap.",
		{"packages": 1},
		""
	))
	
	available_quests.append(Quest.new(
		"quest_2",
		"Quest 2: Trust Gained",
		"Perfect! There was absolutely nothing in that box, that was just a test to prove yourself... and that you did! You've earned my trust and a new Telescopic Upgrade to your ship, you will be able to zoom out more and more with every mission you complete for me. Now, for your REAL first mission, check your map.",
		{"packages": 1},
		"quest_1"
	))
	
	available_quests.append(Quest.new(
		"quest_3",
		"Quest 3: We're Gonna Need A Better Ship",
		"We've been missing this thermal radiation shield for weeks, but rookies like you hardly return after the first mission... Anyways, there's another package with your name on it out there. So, get to it!",
		{"packages": 1},
		"quest_2"
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
			return

func accept_quest(quest_id: String):
	for i in range(available_quests.size()):
		if available_quests[i].id == quest_id:
			var quest = available_quests[i]
			quest.is_active = true
			active_quests.append(quest)
			available_quests.remove_at(i)
			quest_accepted.emit(quest_id)
			tasks_updated.emit()
			print("QUEST ACCEPTED: ", quest.title)
			return

func _on_inventory_changed():
	auto_complete_tasks()
	auto_complete_quests()

func auto_complete_tasks():
	var i = 0
	while i < active_tasks.size():
		var task = active_tasks[i]
		if check_task_completion(task.requirements):
			print("AUTO-COMPLETING TASK: ", task.title)
			complete_task_internal(task)
		else:
			i += 1

func auto_complete_quests():
	var i = 0
	while i < active_quests.size():
		var quest = active_quests[i]
		if check_task_completion(quest.requirements):
			print("AUTO-COMPLETING QUEST: ", quest.title)
			complete_quest_internal(quest)
		else:
			i += 1

func check_task_completion(requirements: Dictionary) -> bool:
	for requirement in requirements:
		var required_amount = requirements[requirement]
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
	
	task.is_completed = true
	completed_tasks.append(task)
	
	for i in range(active_tasks.size()):
		if active_tasks[i].id == task.id:
			active_tasks.remove_at(i)
			break
	
	task_completed.emit(task.id)
	tasks_updated.emit()
	
	print("*TASK COMPLETED: ", task.title)

func complete_quest_internal(quest: Quest):
	for requirement in quest.requirements:
		var required_amount = quest.requirements[requirement]
		match requirement:
			"golden_asteroids":
				GlobalSettings.golden_asteroids -= required_amount
			"packages":
				GlobalSettings.packages -= required_amount
	
	var camera = get_node_or_null("/root/Game/Camera2D")
	if camera:
		camera.packageDelivered()
		print("Quest completed! Telescopic upgrade installed!")
	
	quest.is_completed = true
	completed_quests.append(quest)
	
	unlock_next_quest(quest.id)
	
	for i in range(active_quests.size()):
		if active_quests[i].id == quest.id:
			active_quests.remove_at(i)
			break
	
	quest_completed.emit(quest.id)
	tasks_updated.emit()
	
	print("*QUEST COMPLETED: ", quest.title)

func unlock_next_quest(completed_quest_id: String):
	for quest in available_quests:
		if quest.unlock_after == completed_quest_id:
			quest.is_locked = false
			print("Unlocked quest: ", quest.title)
			tasks_updated.emit()
			break

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

func get_quest_progress(quest: Quest) -> String:
	var progress_parts = []
	
	for requirement in quest.requirements:
		var required_amount = quest.requirements[requirement]
		var current_amount = 0
		
		match requirement:
			"golden_asteroids":
				current_amount = GlobalSettings.golden_asteroids
			"packages":
				current_amount = GlobalSettings.packages
		
		var item_name = requirement.replace("_", " ").capitalize()
		progress_parts.append("%s: %d/%d" % [item_name, current_amount, required_amount])
	
	return " | ".join(progress_parts)

func serialize_task(task: Task) -> Dictionary:
	return {
		"id": task.id,
		"title": task.title,
		"description": task.description,
		"rewards": task.rewards,
		"requirements": task.requirements,
		"is_active": task.is_active,
		"is_completed": task.is_completed
	}

func deserialize_task(data: Dictionary) -> Task:
	var task = Task.new(
		data.get("id", ""),
		data.get("title", ""),
		data.get("description", ""),
		data.get("rewards", {}),
		data.get("requirements", {})
	)
	task.is_active = data.get("is_active", false)
	task.is_completed = data.get("is_completed", false)
	return task

func serialize_quest(quest: Quest) -> Dictionary:
	return {
		"id": quest.id,
		"title": quest.title,
		"quest_lore": quest.quest_lore,
		"requirements": quest.requirements,
		"is_active": quest.is_active,
		"is_completed": quest.is_completed,
		"is_locked": quest.is_locked,
		"unlock_after": quest.unlock_after
	}

func deserialize_quest(data: Dictionary) -> Quest:
	var quest = Quest.new(
		data.get("id", ""),
		data.get("title", ""),
		data.get("quest_lore", ""),
		data.get("requirements", {}),
		data.get("unlock_after", "")
	)
	quest.is_active = data.get("is_active", false)
	quest.is_completed = data.get("is_completed", false)
	quest.is_locked = data.get("is_locked", false)
	return quest
