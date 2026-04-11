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
@export var seed: int = 1
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
		var x = rng.randf_range(xLeftBound, xRightBound)
		var y = rng.randf_range(yDownBound, yUpBound)				
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(1, 3)
		spawn_asteroid(rock_scene, x,y,angle,size)		
		
	#large rock generation
	for i in range(largeRockAmount):
		var x = rng.randf_range(xLeftBound, xRightBound)
		var y = rng.randf_range(yDownBound, yUpBound)				
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
	generateRocks(10, 5, 2, 0, 2, 0, 0, -1500, 1500, 500, 1500)
	#purple
	generateRocks(20, 5, 2, 0, 5, 1, 0, -1500, 1500, -1500, -500)
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
	generateRocks(60, 5, 15, 1, 70, 5, 0, 1600, 5000, -1500, 5000)
	#green
	generateRocks(60, 20, 5, 1, 70, 5, 0, -5000, 1600, -5000, -1600)
	#blue
	generateRocks(40, 0, 0, 2, 50, 5, 0, 1700, 5000, -4500, -1700)
	#special package at -3000, -1550	
	#special package at 4900, -4750
	

	
	#static objects for area 2
	spawn_asteroid(rock_scene, 430,2500,.2,10)
	spawn_asteroid(rock_scene, -2020,1030,2,5)
	spawn_asteroid(rock_scene, 2220,-290,.2,8)
	spawn_asteroid(rock_scene, 1280,-1760,2,7)	
	spawn_asteroid(rock_scene, -1800,-1600,2,6)	

	
			
	#procedural generation for area 3
	#iron
	for i in range(500):
		var x = 0
		var y = 0 
		while( x < 6000 and x > -6000 and y < 6000 and y > -6000  ):
			x = rng.randf_range(-15000, 15000)
			y = rng.randf_range(-15000, 15000)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(iron_asteroid_scene, x,y,angle,size)	
		
	#copper
	for i in range(150):
		var x = 0
		var y = 0 
		while( x < 6000 and x > -6000 and y < 6000 and y > -6000  ):
			x = rng.randf_range(-15000, 15000)
			y = rng.randf_range(-15000, 15000)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(copper_asteroid_scene, x,y,angle,size)	
		
	#cobalt
	for i in range(100):
		var x = 0
		var y = 0 
		while( x < 6000 and x > -6000 and y < 6000 and y > -6000  ):
			x = rng.randf_range(-15000, 15000)
			y = rng.randf_range(-15000, 15000)			
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(cobalt_asteroid_scene, x,y,angle,size)			
		
	#titanium
	for i in range(50):
		var x = 0
		var y = 0 
		while( x < 6000 and x > -6000 and y < 6000 and y > -6000  ):
			x = rng.randf_range(-15000, 15000)
			y = rng.randf_range(-15000, 15000)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(titanium_asteroid_scene, x,y,angle,size)					
	
	#small rocks
	for i in range(800):
		var x = 0
		var y = 0 
		while( x < 6000 and x > -6000 and y < 6000 and y > -6000  ):
			x = rng.randf_range(-15000, 15000)
			y = rng.randf_range(-15000, 15000)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.5, 1)
		spawn_asteroid(rock_scene, x,y,angle,size)	
				
	#big rocks
	for i in range(400):
		var x = 0
		var y = 0 
		while( x < 6000 and x > -6000 and y < 6000 and y > -6000  ):
			x = rng.randf_range(-15000, 15000)
			y = rng.randf_range(-15000, 15000)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.5, 10)
		spawn_asteroid(rock_scene, x,y,angle,size)		
			
			
	#static objects for area 3
