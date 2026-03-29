extends Node2D

@export var iron_asteroid_scene: PackedScene
@export var titanium_asteroid_scene: PackedScene
@export var copper_asteroid_scene: PackedScene
@export var cobalt_asteroid_scene: PackedScene


func spawn_asteroid(scene: PackedScene, position: Vector2):
	var asteroid = scene.instantiate()
	asteroid.position = position
	add_child(asteroid)


func get_random_position():
	var x = randf_range(-100, 100)
	var y = randf_range(-100, 100)
	return Vector2(x, y)

func _ready():
	randomize()
	for i in range(1):
		var pos = get_random_position()
		spawn_asteroid(iron_asteroid_scene, pos)
		
	for i in range(2):
		var pos = get_random_position()
		spawn_asteroid(titanium_asteroid_scene, pos)

	for i in range(1):
		var pos = get_random_position()
		spawn_asteroid(copper_asteroid_scene, pos)
		
	for i in range(30):
		var pos = get_random_position()
		spawn_asteroid(cobalt_asteroid_scene, pos)		
