extends Node
const SAVE_PATH := "user://savegame.save"

func save_game() -> bool:
	var save_data = {
		"ship": get_ship_data(),
		"inventory": get_inventory_data(),
		"tasks": get_task_data(),
		"collected_asteroids": GlobalSettings.collected_asteroid_ids
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully!")
		return true
	else:
		print("Failed to save game!")
		return false

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		print("Game loaded successfully!")
		return save_data
	else:
		print("Failed to load game!")
		return {}

func apply_save_data(save_data: Dictionary):
	if save_data.is_empty():
		print("No save data to apply")
		return
	
	apply_ship_data(save_data.get("ship", {}))
	apply_inventory_data(save_data.get("inventory", {}))
	apply_task_data(save_data.get("tasks", {}))
	
	GlobalSettings.collected_asteroid_ids = save_data.get("collected_asteroids", [])
	remove_collected_asteroids()

func get_ship_data() -> Dictionary:
	var ship = get_node_or_null("/root/Game/Ship")
	if not ship:
		return {}
	
	return {
		"money": ship.money,
		"cobalt": ship.cobalt,
		"titanium": ship.titanium,
		"copper": ship.copper,
		"iron": ship.iron,
		"fuelTier": ship.fuelTier,
		"oxygenTier": ship.oxygenTier,
		"thrusterTier": ship.thrusterTier
	}

func apply_ship_data(data: Dictionary):
	var ship = get_node_or_null("/root/Game/Ship")
	if not ship or data.is_empty():
		return
	
	ship.money = data.get("money", 0)
	ship.cobalt = data.get("cobalt", 0)
	ship.titanium = data.get("titanium", 0)
	ship.copper = data.get("copper", 0)
	ship.iron = data.get("iron", 0)
	ship.fuelTier = data.get("fuelTier", 1)
	ship.oxygenTier = data.get("oxygenTier", 1)
	ship.thrusterTier = data.get("thrusterTier", 1)
	
	ship.add_money(0)
	ship.add_cobalt(0)
	ship.add_titanium(0)
	ship.add_copper(0)
	ship.add_iron(0)

func get_inventory_data() -> Dictionary:
	return {
		"golden_asteroids": GlobalSettings.golden_asteroids,
		"packages": GlobalSettings.packages
	}

func apply_inventory_data(data: Dictionary):
	if data.is_empty():
		return
	
	GlobalSettings.golden_asteroids = data.get("golden_asteroids", 0)
	GlobalSettings.packages = data.get("packages", 0)

func get_task_data() -> Dictionary:
	var available = []
	for task in TaskManager.available_tasks:
		available.append(serialize_task(task))
	
	var active = []
	for task in TaskManager.active_tasks:
		active.append(serialize_task(task))
	
	var completed = []
	for task in TaskManager.completed_tasks:
		completed.append(serialize_task(task))
	
	return {
		"available": available,
		"active": active,
		"completed": completed
	}

func serialize_task(task: TaskManager.Task) -> Dictionary:
	return {
		"id": task.id,
		"title": task.title,
		"description": task.description,
		"rewards": task.rewards,
		"requirements": task.requirements,
		"is_active": task.is_active,
		"is_completed": task.is_completed
	}

func deserialize_task(data: Dictionary) -> TaskManager.Task:
	var task = TaskManager.Task.new(
		data.get("id", ""),
		data.get("title", ""),
		data.get("description", ""),
		data.get("rewards", {}),
		data.get("requirements", {})
	)
	task.is_active = data.get("is_active", false)
	task.is_completed = data.get("is_completed", false)
	return task

func apply_task_data(data: Dictionary):
	if data.is_empty():
		return
	
	TaskManager.available_tasks.clear()
	TaskManager.active_tasks.clear()
	TaskManager.completed_tasks.clear()
	
	for task_data in data.get("available", []):
		TaskManager.available_tasks.append(deserialize_task(task_data))
	
	for task_data in data.get("active", []):
		TaskManager.active_tasks.append(deserialize_task(task_data))
	
	for task_data in data.get("completed", []):
		TaskManager.completed_tasks.append(deserialize_task(task_data))
	
	TaskManager.tasks_updated.emit()

func remove_collected_asteroids():
	await get_tree().process_frame
	
	var all_asteroids = get_tree().get_nodes_in_group("asteroids")
	print("Found ", all_asteroids.size(), " asteroids in scene")
	print("Collected asteroid IDs: ", GlobalSettings.collected_asteroid_ids)
	
	for asteroid in all_asteroids:
		if asteroid.has_meta("asteroid_id"):
			var id = asteroid.get_meta("asteroid_id")
			if id in GlobalSettings.collected_asteroid_ids:
				print("Removing previously collected asteroid: ", id)
				asteroid.queue_free()
				
func reset_all_progress():
	print("=== RESETTING ALL PROGRESS ===")
	
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted")
	
	GlobalSettings.golden_asteroids = 0
	GlobalSettings.packages = 0
	GlobalSettings.collected_asteroid_ids.clear()
	GlobalSettings.camera_lock = false
	GlobalSettings.ez_mode = false
	GlobalSettings.accessibility_mode = false
	
	TaskManager.available_tasks.clear()
	TaskManager.active_tasks.clear()
	TaskManager.completed_tasks.clear()
	TaskManager.create_initial_tasks()
	TaskManager.tasks_updated.emit()
	
	var ship = get_node_or_null("/root/Game/Ship")
	if ship:
		ship.money = 0
		ship.cobalt = 0
		ship.titanium = 0
		ship.copper = 0
		ship.iron = 0
		ship.fuelTier = 1
		ship.oxygenTier = 1
		ship.thrusterTier = 1
		ship.add_money(0)
		ship.add_cobalt(0)
		ship.add_titanium(0)
		ship.add_copper(0)
		ship.add_iron(0)
	
	print("Reloading scene to respawn asteroids...")
	get_tree().reload_current_scene()
	
	print("=== RESET COMPLETE ===")
