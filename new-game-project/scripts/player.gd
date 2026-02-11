extends CharacterBody2D


@export var force: float = 50.0
@export var torque: float = .05
var rotateSpeed = 0
@onready var rocket: AnimatedSprite2D = $AnimatedSprite2D
@onready var respawn_point = get_tree().get_current_scene().get_node("HomeBase/RespawnPoint")
@onready var rocketSound: AudioStreamPlayer = $RocketSounds
@onready var crash: AudioStreamPlayer = $Crash


#Accessibility Mode Variables
@export var decelerationRate:float

func _ready():
	var data = SaveManager.load_game()
	GameController.package_collected = data["package_collected"]


func respawn_to_base():
	var data = SaveManager.load_game()
	global_position = respawn_point.global_position
	
	GameController.package_collected = data["package_collected"]
	GameController.asteroid_collected = data["asteroid_collected"]
	
	velocity = Vector2.ZERO
	rotateSpeed = 0
	rotation = 0

	
func _physics_process(delta: float) -> void:

	# Add the gravity.
	if Input.is_action_pressed("turn_left") and not(Input.is_action_pressed("turn_right")) :
		rotateSpeed -= torque*delta
		
	elif Input.is_action_pressed("turn_right") and not(Input.is_action_pressed("turn_left")):
		rotateSpeed += torque*delta
	else:
		if AccessibilityHandler.isAccessibilityEnabled: #IF accessibility mode is on we want rotation to be non inertial
			rotateSpeed = 0
	
	rotation += rotateSpeed
		
	if Input.is_action_pressed("thrust"):
		velocity += Vector2.UP.rotated(rotation)*force*delta
		rocket.play("thrust")
		if not rocketSound.playing:
			rocketSound.play()
	else:
		if AccessibilityHandler.isAccessibilityEnabled:
			#IF accessibility is active, add deceleration to improve movement
			if velocity.length()>0:
				velocity = velocity.lerp(Vector2.ZERO, delta*decelerationRate)
		
		rocket.play("default")
		if  rocketSound.playing:
			rocketSound.stop()	
		

	var collision = move_and_collide(velocity * delta)
	if collision:
		print("Collision Detected, respawning...")
		crash.play()
		respawn_to_base()
			
