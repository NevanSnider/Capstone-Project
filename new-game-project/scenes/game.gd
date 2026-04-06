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



func _ready():
	
	#start soundtrack
	actionTheme.play()
	
	
	print("=== PROCEDURAL GENERATION _READY CALLED ===")
	
	rng.seed = seed
	
	#create starting objects
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
	#iron
	for i in range(40):
		var x = 0
		var y = 0 
		while( x < 500 and x > -500 and y < 500 and y > -500  ):
			x = rng.randf_range(-1500, 1500)
			y = rng.randf_range(-1500, 1500)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(iron_asteroid_scene, x,y,angle,size)	
		
	#copper
	for i in range(15):
		var x = 0
		var y = 0 
		while( x < 500 and x > -500 and y < 500 and y > -500  ):
			x = rng.randf_range(-1500, 1500)
			y = rng.randf_range(-1500, 1500)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(copper_asteroid_scene, x,y,angle,size)	
		
	#cobalt
	for i in range(5):
		var x = 0
		var y = 0 
		while( x < 500 and x > -500 and y < 500 and y > -500  ):
			x = rng.randf_range(-1500, 1500)
			y = rng.randf_range(-1500, 1500)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(cobalt_asteroid_scene, x,y,angle,size)			
		
	#rocks
	for i in range(5):
		var x = 0
		var y = 0 
		while( x < 500 and x > -500 and y < 500 and y > -500  ):
			x = rng.randf_range(-1500, 1500)
			y = rng.randf_range(-1500, 1500)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.5, 1.25)
		spawn_asteroid(rock_scene, x,y,angle,size)	
		
		
	#procedural generation for area 2
	#iron
	for i in range(125):
		var x = 0
		var y = 0 
		while( x < 1600 and x > -1600 and y < 1600 and y > -1600  ):
			x = rng.randf_range(-5000, 5000)
			y = rng.randf_range(-5000, 5000)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(iron_asteroid_scene, x,y,angle,size)	
		
	#copper
	for i in range(25):
		var x = 0
		var y = 0 
		while( x < 1600 and x > -1600 and y < 1600 and y > -1600  ):
			x = rng.randf_range(-5000, 5000)
			y = rng.randf_range(-5000, 5000)	
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(copper_asteroid_scene, x,y,angle,size)	
		
	#cobalt
	for i in range(15):
		var x = 0
		var y = 0 
		while( x < 1600 and x > -1600 and y < 1600 and y > -1600  ):
			x = rng.randf_range(-5000, 5000)
			y = rng.randf_range(-5000, 5000)		
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(cobalt_asteroid_scene, x,y,angle,size)			
		
	#titanium
	for i in range(5):
		var x = 0
		var y = 0 
		while( x < 1600 and x > -1600 and y < 1600 and y > -1600  ):
			x = rng.randf_range(-5000, 5000)
			y = rng.randf_range(-5000, 5000)	
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.8, 1.2)
		spawn_asteroid(titanium_asteroid_scene, x,y,angle,size)					
		
	#big rocks
	for i in range(50):
		var x = 0
		var y = 0 
		while( x < 1600 and x > -1600 and y < 1600 and y > -1600  ):
			x = rng.randf_range(-5000, 5000)
			y = rng.randf_range(-5000, 5000)
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.5, 4)
		spawn_asteroid(rock_scene, x,y,angle,size)		
		
	#small rocks
	for i in range(50):
		var x = 0
		var y = 0 
		while( x < 1600 and x > -1600 and y < 1600 and y > -1600  ):
			x = rng.randf_range(-5000, 5000)
			y = rng.randf_range(-5000, 5000)
		var angle = rng.randf_range(0.0, TAU)
		var size = rng.randf_range(0.5, 1)
		spawn_asteroid(rock_scene, x,y,angle,size)				
		
	#static objects for area 2
	spawn_asteroid(rock_scene, 430,2500,.2,10)
	spawn_asteroid(rock_scene, -2020,1030,2,5)
	spawn_asteroid(rock_scene, 2220,-290,.2,8)
	spawn_asteroid(rock_scene, 1480,-1960,2,7)	
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
