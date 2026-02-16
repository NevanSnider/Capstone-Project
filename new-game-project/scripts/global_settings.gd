extends Node

var camera_lock: bool = false
var ez_mode: bool = false
var accessibility_mode: bool = false

func save_settings():
	var config = ConfigFile.new()
	config.set_value("gameplay", "camera_lock", camera_lock)
	config.set_value("gameplay", "ez_mode", ez_mode)
	config.set_value("gameplay", "accessibility_mode", accessibility_mode)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		camera_lock = config.get_value("gameplay", "camera_lock", false)
		ez_mode = config.get_value("gameplay", "ez_mode", false)
		accessibility_mode = config.get_value("gameplay", "accessibility_mode", false)

func _ready():
	load_settings()
