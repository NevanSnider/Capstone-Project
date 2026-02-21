extends CharacterBody2D

var fuelTier: int = 1
var oxygenTier: int = 1
var thrusterTier: int = 1

var maxFuel: int = 1
var fuel: int = maxFuel
var maxOxygen: int = 1
var oxygen: int = maxOxygen

var baseMass: int = 30000
var currentMass: int = 30000+fuel

var handlingConstant: int = 50000

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
	
	if(fuelTier == 1):
		maxFuel = 14000
	elif(fuelTier == 2):
		maxFuel = 22000
	elif(fuelTier == 3):
		maxFuel = 30000		
	elif(fuelTier == 4):
		maxFuel = 40000				
		
	if(oxygenTier == 1):
		maxOxygen = 60000
	elif(oxygenTier == 2):
		maxOxygen = 120000
	elif(oxygenTier == 3):
		maxOxygen = 200000		
	elif(oxygenTier == 4):
		maxOxygen = 300000	
	elif(oxygenTier == 5):
		maxOxygen = 400000		
		
	if(thrusterTier == 1):
		force = 25
		torque = .025
	elif(thrusterTier == 2):
		force = 50
		torque = .05	
	elif(thrusterTier == 3):
		force = 75
		torque = .075
		
	currentMass = 30000+fuel
	# Add the gravity.
	if Input.is_action_pressed("turn_left") and not(Input.is_action_pressed("turn_right") and fuel > 0) :
		rotateSpeed -= torque*delta*handlingConstant/currentMass
		fuel -= 5
		
	elif Input.is_action_pressed("turn_right") and not(Input.is_action_pressed("turn_left") and fuel > 0):
		rotateSpeed += torque*delta*handlingConstant/currentMass
		fuel -= 5
		
	else:
		if AccessibilityHandler.isAccessibilityEnabled: #IF accessibility mode is on we want rotation to be non inertial
			rotateSpeed = 0
	
	rotation += rotateSpeed
		
	if (Input.is_action_pressed("thrust")  and fuel > 0):
		velocity += Vector2.UP.rotated(rotation)*force*delta*handlingConstant/currentMass
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

	#print(force*delta*45000/currentMass)
	#print("Fuel Remaining: ", float(fuel)/maxFuel)		
	#print("Oxygen Remaining: ", float(oxygen)/maxOxygen)		

			
#Adds money to the balance when an asteroid is collected and updates the shop menu interface
func add_money(amount):
	money += amount;
	$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)

# These are all the buttons attached to specific upgrades. When upgrades are added it
# will require a specific amount of money to purchase the item

#Oxygen Upgrades
func _on_button_2_pressed() -> void:
	if (oxygenTier == 1):
		if (money >= 100):
			oxygenTier += 1
			money -= 100
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 2"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit2".text = "Increase Oxygen Tank\nMaximum. $200"

			
	if (oxygenTier == 2):
		if (money >= 200):
			oxygenTier += 1
			money -= 200
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit2".text = "Increase Oxygen Tank\nMaximum. $300"
			
			
	if (oxygenTier == 3):
		if (money >= 300):
			oxygenTier += 1
			money -= 300
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 4"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit2".text = "Increase Oxygen Tank\nMaximum. $400"
			
	if (oxygenTier == 4):
		if (money >= 400):
			oxygenTier += 1
			money -= 400
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Max Reached"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit2".text = ""

#fuel upgrades
func _on_button_pressed() -> void:
	if (fuelTier == 1):
		if (money >= 100):
			fuelTier += 1
			money -= 100
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 2"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum. $200"
			
	if (fuelTier == 2):
		if (money >= 200):
			fuelTier += 1
			money -= 200
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum. $300"
			
	if (fuelTier == 3):
		if (money >= 300):
			fuelTier += 1
			money -= 300
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 4"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum. $400"
			
	if (fuelTier == 4):
		if (money >= 400):
			fuelTier += 1
			money -= 400
			$"../CanvasLayer/Shop/Button".text = "Fuel Max Reached"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum. $400"

#Thruster upgrades
func _on_button_3_pressed() -> void:
	if (thrusterTier == 1):
		if (money >= 100):
			thrusterTier += 1
			money -= 100
			$"../CanvasLayer/Shop/Button3".text = "Thruster Tier 2"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit".text = ""
			
	if (thrusterTier == 2):
		if (money >= 200):
			thrusterTier += 1
			money -= 200
			$"../CanvasLayer/Shop/Button3".text = "Thruster Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			
	if (thrusterTier == 3):
		if (money >= 300):
			thrusterTier += 1
			money -= 300
			$"../CanvasLayer/Shop/Button3".text = "Thruster Max Reached"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
