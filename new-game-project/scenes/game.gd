extends Node2D

@export var iron_asteroid_scene: PackedScene
@export var titanium_asteroid_scene: PackedScene
@export var copper_asteroid_scene: PackedScene
@export var cobalt_asteroid_scene: PackedScene
@export var rock_scene: PackedScene

@onready var actionTheme: AudioStreamPlayer = $actionTheme

#generate random number
var rng = RandomNumberGenerator.new()

#change this to a specific value to make it 
@export var seed: int = 2
#@export var seed: int = randf_range(0, 99999)

func spawn_asteroid(scene: PackedScene, x, y, angle, size):
	var asteroid = scene.instantiate()
	
	asteroid.position = Vector2(x, -y)
	
	asteroid.rotation = angle
	
	asteroid.scale = Vector2(size, size)
	
	add_child(asteroid)

func generateRocks(ironAmount, copperAmount, cobaltAmount, titaniumAmount, smallRockAmount, mediumRockAmount, largeRockAmount, xLeftBound, xRightBound, yDownBound, yUpBound):
	#iron generation
	for i in range(ironAmount):
		var x = rng.randf_range(xLeftBound, xRightBound)
		var y = rng.randf_range(yDownBound, yUpBound)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(iron_asteroid_scene, x,y,angle,size)	
	
	#copperAmount generation
	for i in range(copperAmount):
		var x = rng.randf_range(xLeftBound, xRightBound)
		var y = rng.randf_range(yDownBound, yUpBound)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(copper_asteroid_scene, x,y,angle,size)	
		
	#cobaltAmount generation
	for i in range(cobaltAmount):
		var x = rng.randf_range(xLeftBound, xRightBound)
		var y = rng.randf_range(yDownBound, yUpBound)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(cobalt_asteroid_scene, x,y,angle,size)			
		
	#titaniumAmount generation
	for i in range(titaniumAmount):
		var x = rng.randf_range(xLeftBound, xRightBound)
		var y = rng.randf_range(yDownBound, yUpBound)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(titanium_asteroid_scene, x,y,angle,size)				
		
	#small rock generation
	for i in range(smallRockAmount):
		var x = rng.randf_range(xLeftBound, xRightBound)
		var y = rng.randf_range(yDownBound, yUpBound)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.5, 1)
		spawn_asteroid(rock_scene, x,y,angle,size)			
		
	#medium rock generation
	for i in range(mediumRockAmount):
		var x = rng.randf_range(xLeftBound+100, xRightBound-100)
		var y = rng.randf_range(yDownBound+100, yUpBound-100)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(1, 3)
		spawn_asteroid(rock_scene, x,y,angle,size)		
		
	#large rock generation
	for i in range(largeRockAmount):
		var x = rng.randf_range(xLeftBound+1000, xRightBound-1000)
		var y = rng.randf_range(yDownBound+1000, yUpBound-1000)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(3, 10)
		spawn_asteroid(rock_scene, x,y,angle,size)									

func _ready():
	
	#start soundtrack
	actionTheme.play()
	
	
	print("=== PROCEDURAL GENERATION _READY CALLED ===")
	
	rng.seed = seed
	
	#create starting objects (red)
	#iron
	spawn_asteroid(iron_asteroid_scene, 30,100,0,1)
	spawn_asteroid(iron_asteroid_scene, 260,270,0.5,1.2)
	spawn_asteroid(iron_asteroid_scene, -220,-230,1,0.9)
	spawn_asteroid(iron_asteroid_scene, 250,-90,1.5,1.1)
	
	spawn_asteroid(cobalt_asteroid_scene, -30,200,.5,1)

	spawn_asteroid(copper_asteroid_scene, -290,350,0,1)
	spawn_asteroid(copper_asteroid_scene, -570,130,0.5,1)
	
	spawn_asteroid(rock_scene, -500,130,0,1)
	spawn_asteroid(rock_scene, 450,-310,1,0.785)
	
	
	#procedural generation for area 1
	#orange
	generateRocks(10, 3, 2, 0, 2, 0, 0, -1500, 1500, 500, 1500)
	#purple
	generateRocks(20, 3, 2, 0, 5, 1, 0, -1500, 1500, -1500, -500)
	#cyan	
	generateRocks(5, 1, 1, 0, 0, 0, 0, -1500, -500, -500, 500)
	#yellow	
	generateRocks(5, 3, 0, 0, 1, 1, 0, 500, 1400, -500, 500)
	#special package at 1450, -450


	#procedural generation for area 2 
	#yellow
	generateRocks(80, 10, 5, 1, 10, 0, 0, -5000, -1600, -1500, 5000)
	#pink
	generateRocks(80, 5, 5, 0, 25, 5, 0, -1600, 1600, 1500, 5000)
	#cyan
	generateRocks(70, 5, 15, 1, 70, 5, 0, 1600, 5000, -1500, 5000)
	#green
	generateRocks(70, 30, 5, 1, 70, 5, 0, -5000, 1600, -5000, -1600)
	#blue
	generateRocks(60, 0, 0, 5, 50, 5, 0, 1700, 5000, -4800, -1700)
	#special package at -3000, -1550	
	#special package at 4900, -4750
	

	
	#static objects for area 2
	spawn_asteroid(rock_scene, 430,2500,.2,10)
	spawn_asteroid(rock_scene, -2020,1030,2,5)
	spawn_asteroid(rock_scene, 2220,-290,.2,8)
	spawn_asteroid(rock_scene, 1280,-1760,2,7)	
	spawn_asteroid(rock_scene, -1800,-1600,2,6)	

	
	
	#procedural generation for area 3
	#red
	generateRocks(300, 50, 20, 10, 400, 40, 4, -15000, -5000, -5000, 14700)
	#pink
	generateRocks(800, 50, 300, 20, 500, 200, 20, -15000, 5000, -15000, -5100)
	#purple
	generateRocks(600, 600, 15, 10, 1000, 100, 10, -5000, 14700, 5000, 15000)
	#yellow
	generateRocks(500, 20, 10, 10, 1000, 5, 1, 5000, 15000, -5000, 5000)	
	#orange
	generateRocks(500, 100, 50, 500, 1500, 100, 10, 5000, 14700, -15000, -5000)
	
	#special package at -10000, -5050
	#special package at -14900, 14900
	#special package at 14900, 10000	
	#special package at 14900, -14900
	

			
	
	#procedural generation for area 4
	generateRocks(1000, 5, 5, 5, 500, 50, 5, -20000, -15000, -20000, 20000)
	generateRocks(1000, 5, 5, 5, 500, 50, 5, 15000, 20000, -20000, 20000)
	generateRocks(1000, 5, 5, 5, 500, 50, 5, -20000, 20000, 15000, 20000)
	generateRocks(1000, 5, 5, 5, 500, 50, 5, -20000, 20000, -20000, -15000)

	#procedural generation for area 5
	generateRocks(5, 5, 5, 5, 500, 500, 500, -40000, -20000, -40000, 40000)
	generateRocks(5, 5, 5, 5, 500, 500, 500, 20000, 40000, -40000, 40000)
	generateRocks(2, 2, 2, 2, 200, 200, 200, -20000, 20000, 20000, 40000)
	generateRocks(2, 2, 2, 2, 200, 200, 200, -20000, 20000, -40000, -20000)	
	
	#procedural generation for area 6
	generateRocks(0, 0, 0, 0, 0, 0, 50, -60000, -40000, -60000, 60000)
	generateRocks(0, 0, 0, 0, 0, 0, 50, 40000, 60000, -60000, 60000)
	generateRocks(0, 0, 0, 0, 0, 0, 20, -40000, 40000, 40000, 60000)
	generateRocks(0, 0, 0, 0, 0, 0, 20, -40000, 40000, -60000, -40000)	
	
			
