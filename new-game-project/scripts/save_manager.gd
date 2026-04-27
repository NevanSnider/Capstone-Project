extends Node

const SAVE_SLOT_1 = "user://savegame_slot1.save"
const SAVE_SLOT_2 = "user://savegame_slot2.save"
const SAVE_SLOT_3 = "user://savegame_slot3.save"

var current_slot: int = 1

func get_save_path(slot: int) -> String:
	match slot:
		1:
			return SAVE_SLOT_1
		2:
			return SAVE_SLOT_2
		3:
			return SAVE_SLOT_3
		_:
			return SAVE_SLOT_1

func save_game_to_slot(slot: int) -> bool:
	var game_scene = get_node_or_null("/root/Game")
	var world_seed = 1
	if game_scene:
		world_seed = game_scene.get("seed")
		if world_seed == null:
			world_seed = 1
	
	var save_data = {
		"ship": get_ship_data(),
		"inventory": get_inventory_data(),
		"tasks": get_task_data(),
		"collected_asteroids": GlobalSettings.collected_asteroid_ids,
		"world_seed": world_seed,
		"save_date": Time.get_datetime_string_from_system(),
		"slot": slot
	}
	
	var save_path = get_save_path(slot)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved to slot ", slot, "!")
		return true
	else:
		print("Failed to save game to slot ", slot, "!")
		return false

func load_game_from_slot(slot: int) -> Dictionary:
	var save_path = get_save_path(slot)
	
	if not FileAccess.file_exists(save_path):
		print("No save file found in slot ", slot)
		return {}
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		print("Game loaded from slot ", slot, "!")
		return save_data
	else:
		print("Failed to load game from slot ", slot, "!")
		return {}

func get_save_info(slot: int) -> Dictionary:
	var save_path = get_save_path(slot)
	
	if not FileAccess.file_exists(save_path):
		return {"exists": false}
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		return {
			"exists": true,
			"date": save_data.get("save_date", "Unknown"),
			"world_seed": save_data.get("world_seed", 1),
			"slot": slot
		}
	else:
		return {"exists": false}

func delete_save_slot(slot: int) -> bool:
	var save_path = get_save_path(slot)
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		print("Deleted save slot ", slot)
		return true
	return false

func save_game() -> bool:
	return save_game_to_slot(current_slot)

func load_game() -> Dictionary:
	return load_game_from_slot(current_slot)

func apply_save_data(save_data: Dictionary):
	if save_data.is_empty():
		print("No save data to apply")
		return
	
	apply_ship_data(save_data.get("ship", {}))
	apply_inventory_data(save_data.get("inventory", {}))
	apply_task_data(save_data.get("tasks", {}))
	
	GlobalSettings.collected_asteroid_ids = save_data.get("collected_asteroids", [])
	
	var game_scene = get_node_or_null("/root/Game")
	if game_scene:
		var world_seed = save_data.get("world_seed", 1)
		game_scene.seed = world_seed
		print("Set world seed to: ", world_seed)
	
	remove_collected_asteroids()

func get_ship_data() -> Dictionary:
	var ship = get_node_or_null("/root/Game/Ship")
	var camera = get_node_or_null("/root/Game/Camera2D")
	
	if not ship:
		return {}
	
	var data = {
		"money": ship.money,
		"cobalt": ship.cobalt,
		"titanium": ship.titanium,
		"copper": ship.copper,
		"iron": ship.iron,
		"fuelTier": ship.fuelTier,
		"oxygenTier": ship.oxygenTier,
		"thrusterTier": ship.thrusterTier,
		"position": ship.global_position,
		"velocity": ship.velocity,
		"rotation": ship.rotation,
		"fuel": ship.fuel,
		"oxygen": ship.oxygen
	}
	
	if camera:
		data["zoomTier"] = camera.zoomTier
	
	return data

func apply_ship_data(data: Dictionary):
	var ship = get_node_or_null("/root/Game/Ship")
	var camera = get_node_or_null("/root/Game/Camera2D")
	
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
	
	if data.has("position"):
		ship.global_position = data.get("position")
	if data.has("velocity"):
		ship.velocity = data.get("velocity")
	if data.has("rotation"):
		ship.rotation = data.get("rotation")
	if data.has("fuel"):
		ship.fuel = data.get("fuel")
	if data.has("oxygen"):
		ship.oxygen = data.get("oxygen")
	
	if camera and data.has("zoomTier"):
		camera.zoomTier = data.get("zoomTier", 1)
		camera.packageDelivered()
	
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
		available.append(TaskManager.serialize_task(task))
	
	var active = []
	for task in TaskManager.active_tasks:
		active.append(TaskManager.serialize_task(task))
	
	var completed = []
	for task in TaskManager.completed_tasks:
		completed.append(TaskManager.serialize_task(task))
	
	var available_quests = []
	for quest in TaskManager.available_quests:
		available_quests.append(TaskManager.serialize_quest(quest))
	
	var active_quests = []
	for quest in TaskManager.active_quests:
		active_quests.append(TaskManager.serialize_quest(quest))
	
	var completed_quests = []
	for quest in TaskManager.completed_quests:
		completed_quests.append(TaskManager.serialize_quest(quest))
	
	return {
		"available": available,
		"active": active,
		"completed": completed,
		"available_quests": available_quests,
		"active_quests": active_quests,
		"completed_quests": completed_quests
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
	TaskManager.available_quests.clear()
	TaskManager.active_quests.clear()
	TaskManager.completed_quests.clear()
	
	for task_data in data.get("available", []):
		TaskManager.available_tasks.append(TaskManager.deserialize_task(task_data))
	
	for task_data in data.get("active", []):
		TaskManager.active_tasks.append(TaskManager.deserialize_task(task_data))
	
	for task_data in data.get("completed", []):
		TaskManager.completed_tasks.append(TaskManager.deserialize_task(task_data))
	
	for quest_data in data.get("available_quests", []):
		TaskManager.available_quests.append(TaskManager.deserialize_quest(quest_data))
	
	for quest_data in data.get("active_quests", []):
		TaskManager.active_quests.append(TaskManager.deserialize_quest(quest_data))
	
	for quest_data in data.get("completed_quests", []):
		TaskManager.completed_quests.append(TaskManager.deserialize_quest(quest_data))
	
	TaskManager.tasks_updated.emit()

func remove_collected_asteroids():
	await get_tree().process_frame
	
	var all_asteroids = get_tree().get_nodes_in_group("asteroids")
	print("Found ", all_asteroids.size(), " asteroids in scene")
	print("Permanently collected asteroid IDs: ", GlobalSettings.collected_asteroid_ids)
	
	for asteroid in all_asteroids:
		if asteroid.has_meta("asteroid_id"):
			var id = asteroid.get_meta("asteroid_id")
			if id in GlobalSettings.collected_asteroid_ids:
				print("Removing permanently collected asteroid: ", id)
				asteroid.queue_free()

func reset_all_progress():
	print("=== RESETTING ALL PROGRESS ===")
	
	for slot in [1, 2, 3]:
		delete_save_slot(slot)
	
	GlobalSettings.golden_asteroids = 0
	GlobalSettings.packages = 0
	GlobalSettings.collected_asteroid_ids.clear()
	GlobalSettings.temporary_collected_ids.clear()
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

func auto_save():
	var slot = GlobalSettings.current_save_slot
	
	if slot <= 0:
		print("No save slot selected — skipping autosave")
		return
	
	save_game_to_slot(slot)
	print("Autosaved to slot ", slot)
