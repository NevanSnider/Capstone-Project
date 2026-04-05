extends Node

signal inventory_changed  

var camera_lock: bool = false
var ez_mode: bool = false
var accessibility_mode: bool = false

# Inventory
var golden_asteroids: int = 0:
	set(value):
		golden_asteroids = value
		inventory_changed.emit()
		
var cobalt_asteroids: int = 0:
	set(value):
		cobalt_asteroids = value
		inventory_changed.emit()
		
var copper_asteroids: int = 0:
	set(value):
		copper_asteroids = value
		inventory_changed.emit()
		
var iron_asteroids: int = 0:
	set(value):
		iron_asteroids = value
		inventory_changed.emit()
		
var titanium_asteroids: int = 0:
	set(value):
		titanium_asteroids = value
		inventory_changed.emit()

var packages: int = 0:
	set(value):
		packages = value
		inventory_changed.emit()

var collected_asteroid_ids: Array = []
var temporary_collected_ids: Array = []

func save_settings():
	var config = ConfigFile.new()
	config.set_value("gameplay", "camera_lock", camera_lock)
	config.set_value("gameplay", "ez_mode", ez_mode)
	config.set_value("gameplay", "accessibility_mode", accessibility_mode)
	config.set_value("inventory", "golden_asteroids", golden_asteroids)
	config.set_value("inventory", "cobalt_asteroids", cobalt_asteroids)
	config.set_value("inventory", "copper_asteroids", copper_asteroids)
	config.set_value("inventory", "iron_asteroids", iron_asteroids)
	config.set_value("inventory", "titanium_asteroids", titanium_asteroids)
	config.set_value("inventory", "packages", packages)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		camera_lock = config.get_value("gameplay", "camera_lock", false)
		ez_mode = config.get_value("gameplay", "ez_mode", false)
		accessibility_mode = config.get_value("gameplay", "accessibility_mode", false)
		golden_asteroids = config.get_value("inventory", "golden_asteroids", 0)
		cobalt_asteroids = config.get_value("inventory", "cobalt_asteroids", 0)
		copper_asteroids = config.get_value("inventory", "copper_asteroids", 0)
		iron_asteroids = config.get_value("inventory", "iron_asteroids", 0)
		titanium_asteroids = config.get_value("inventory", "titanium_asteroids", 0)
		packages = config.get_value("inventory", "packages", 0)

func _ready():
	load_settings()
	
func commit_temporary_collections():
	for id in temporary_collected_ids:
		if not id in collected_asteroid_ids:
			collected_asteroid_ids.append(id)
	temporary_collected_ids.clear()
