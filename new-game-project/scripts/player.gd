extends CharacterBody2D

var maxFuel: int = 30000
var fuel: int = maxFuel
var maxOxygen: int = 300000
var oxygen: int = maxOxygen

var money: int = 0
@export var force: float = 50.0
@export var torque: float = .05
var rotateSpeed = 0
@onready var rocket: AnimatedSprite2D = $AnimatedSprite2D
@onready var respawn_point = get_tree().get_current_scene().get_node("HomeBase/RespawnPoint")
@onready var rocketSound: AudioStreamPlayer = $RocketSounds
@onready var crash: AudioStreamPlayer = $Crash


#Accessibility Mode Variables
@export var decelerationRate:float

func _on_player_entered_base():
	print("Base message received")
	fuel = maxFuel
	oxygen = maxOxygen
	
	
func _ready():
	var data = SaveManager.load_game()
	GameController.package_collected = data["package_collected"]
	
	var home_base = get_tree().get_current_scene().get_node("HomeBase")
	home_base.player_entered_base.connect(_on_player_entered_base)


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
	if Input.is_action_pressed("turn_left") and not(Input.is_action_pressed("turn_right") and fuel > 0) :
		rotateSpeed -= torque*delta
		fuel -= 5
		
	elif Input.is_action_pressed("turn_right") and not(Input.is_action_pressed("turn_left") and fuel > 0):
		rotateSpeed += torque*delta
		fuel -= 5
		
	else:
		if AccessibilityHandler.isAccessibilityEnabled: #IF accessibility mode is on we want rotation to be non inertial
			rotateSpeed = 0
	
	rotation += rotateSpeed
		
	if (Input.is_action_pressed("thrust")  and fuel > 0):
		velocity += Vector2.UP.rotated(rotation)*force*delta
		fuel -= 10
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
	if collision or oxygen  < 0:
		print("Collision Detected, respawning...")
		crash.play()
		respawn_to_base()
		
	oxygen -= 10

	print("Fuel Remaining: ", float(fuel)/maxFuel)		
	print("Oxygen Remaining: ", float(oxygen)/maxOxygen)		

			
#Adds money to the balance when an asteroid is collected and updates the shop menu interface
func add_money(amount):
	money += amount;
	$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)

# These are all the buttons attached to specific upgrades. When upgrades are added it
# will require a specific amount of money to purchase the item
func _on_button_2_pressed() -> void:
	if (money < 0):
		pass
	pass # Replace with function body.

func _on_button_pressed() -> void:
	if (money < 0):
		pass
	pass # Replace with function body.

func _on_button_3_pressed() -> void:
	if (money < 0):
		pass
	pass # Replace with function body.

func _on_button_4_pressed() -> void:
	if (money < 0):
		pass
	pass # Replace with function body.
