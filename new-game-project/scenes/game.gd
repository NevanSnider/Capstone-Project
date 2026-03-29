extends Node2D

@export var iron_asteroid_scene: PackedScene
@export var titanium_asteroid_scene: PackedScene
@export var copper_asteroid_scene: PackedScene
@export var cobalt_asteroid_scene: PackedScene
@export var rock_scene: PackedScene


func spawn_asteroid(scene: PackedScene, position: Vector2):
	var asteroid = scene.instantiate()
	
	asteroid.position = position
	
	# random rotation (0 to 360 degrees)
	asteroid.rotation = randf_range(0.0, TAU)
	
	# random uniform scale (adjust range as you like)
	var s = randf_range(0.5, 1.5)
	asteroid.scale = Vector2(s, s)
	
	add_child(asteroid)


func get_random_position():
	var x = randf_range(-1000, 1000)
	var y = randf_range(-1000, 1000)
	return Vector2(x, y)

func _ready():
	randomize()
	for i in range(10):
		var pos = get_random_position()
		spawn_asteroid(iron_asteroid_scene, pos)
		
	for i in range(10):
		var pos = get_random_position()
		spawn_asteroid(titanium_asteroid_scene, pos)

	for i in range(10):
		var pos = get_random_position()
		spawn_asteroid(copper_asteroid_scene, pos)
		
	for i in range(10):
		var pos = get_random_position()
		spawn_asteroid(cobalt_asteroid_scene, pos)		
		
	for i in range(5):
		var pos = get_random_position()
		spawn_asteroid(rock_scene, pos)		
