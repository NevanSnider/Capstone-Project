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
var cobalt: int = 0
var copper: int = 0
var titanium: int = 0
var iron: int = 0

@export var force: float = 50.0
@export var torque: float = .05
var rotateSpeed = 0
@onready var rocket: AnimatedSprite2D = $AnimatedSprite2D
@onready var side_thrusters: AnimatedSprite2D = $AnimatedSprite2D2
@onready var respawn_point = get_tree().get_current_scene().get_node("HomeBase/RespawnPoint")
@onready var rocketSound: AudioStreamPlayer = $RocketSounds
@onready var turnRocketSound: AudioStreamPlayer = $TurnRocketSounds

@onready var crash: AudioStreamPlayer = $Crash


#Accessibility Mode Variables
@export var decelerationRate:float
@export var accessibilityRotationSpeed:float
@export var accesibilityLinearSpeed:float

var _ws_client = WebSocketPeer.new()
var _is_connected = false

var server_url = "ws://127.0.0.1:5555"

func _on_player_entered_base():
	#print("Base message received")
	fuel = maxFuel
	oxygen = maxOxygen
	if(not(Input.is_action_pressed("turn_left")) and not(Input.is_action_pressed("turn_right")) and not(Input.is_action_pressed("thrust"))):
		velocity = velocity *0.9
		rotateSpeed = rotateSpeed * 0.9

	

func _ready():
	var data = SaveManager.load_game()
	GameController.package_collected = data["package_collected"]
	
	var home_base = get_tree().get_current_scene().get_node("HomeBase")
	home_base.player_entered_base.connect(_on_player_entered_base)
	
	
	# Attempt to connect to the WebSocket server
	var err = _ws_client.connect_to_url(server_url)
	if err != OK:
		print("Error connecting to server.")
	else:
		print("Connection initiated.")
		_is_connected=true

	
	
func _handle_command(packet:String):
	print(packet)
	#respawn function
func respawn_to_base():
	var data = SaveManager.load_game()
	global_position = respawn_point.global_position
	
	GameController.package_collected = data["package_collected"]
	GameController.asteroid_collected = data["asteroid_collected"]
	
	velocity = Vector2.ZERO
	rotateSpeed = 0
	rotation = 0

	
func _physics_process(delta: float) -> void:
	var packetDict
	if AccessibilityHandler.isAccessibilityEnabled:
		_ws_client.poll()
		var state = _ws_client.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			if not _is_connected:
				_is_connected = true
				print("Successfully connected to vision server!")

			# Check if there are any messages waiting
			while _ws_client.get_available_packet_count() > 0:
				var packet = _ws_client.get_packet()
				# Packets are byte arrays, so we need to convert to string
				packetDict =JSON.parse_string(packet.get_string_from_utf8())


		elif state == WebSocketPeer.STATE_CLOSING:
			# Keep polling until fully closeds
			pass
		elif state == WebSocketPeer.STATE_CLOSED:
			if _is_connected:
				_is_connected = false
				print("Connection to vision server lost.")
	
	#implement tiers
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
		
	#add comand to cheat in resources
	if Input.is_action_pressed("cheat"):
		add_money(1000)
		add_iron(1000)
		add_cobalt(1000)
		add_copper(1000)
		add_titanium(1000)
		
		
	currentMass = 30000+fuel
	# Add the gravity.
	if Input.is_action_pressed("turn_left") and not Input.is_action_pressed("turn_right") and fuel > 0:
		rotateSpeed -= torque*delta*handlingConstant/currentMass
		fuel -= 5
		side_thrusters.play("right thrust")
		if not turnRocketSound.playing:
			turnRocketSound.play()		
		
	elif Input.is_action_pressed("turn_right") and not Input.is_action_pressed("turn_left") and fuel > 0:
		rotateSpeed += torque*delta*handlingConstant/currentMass
		fuel -= 5
		side_thrusters.play("left thrust")
		if not turnRocketSound.playing:
			turnRocketSound.play()		
					
	elif AccessibilityHandler.isAccessibilityEnabled and packetDict:
		
		var headTiltAngle = float(packetDict.get("head_tilt","0"))
		if(headTiltAngle>15):
			fuel-=5
			rotateSpeed = accessibilityRotationSpeed * delta
		elif (headTiltAngle<-15):
			rotateSpeed = accessibilityRotationSpeed * delta * -1
			fuel-=5
		else:
			rotateSpeed=0
		
	else:
		side_thrusters.play("default")
		if AccessibilityHandler.isAccessibilityEnabled: #IF accessibility mode is on we want rotation to be non inertial
			rotateSpeed = 0
		if  turnRocketSound.playing:
			turnRocketSound.stop()				
	
	rotation += rotateSpeed
		
	if (Input.is_action_pressed("thrust") and fuel > 0):
		velocity += Vector2.UP.rotated(rotation)*force*delta*handlingConstant/currentMass
		fuel -= 10
		rocket.play("thrust")
		if not rocketSound.playing:
			rocketSound.play()
	else:
		if AccessibilityHandler.isAccessibilityEnabled and packetDict:
			#IF accessibility is active, add deceleration to improve movement
			var mouthOpen = bool(packetDict.get("mouth_open"))
			if mouthOpen:
				velocity += Vector2.UP.rotated(rotation)*delta*accesibilityLinearSpeed
				rocket.play("thrust")
				if not rocketSound.playing:
					rocketSound.play()
				fuel-=10
			else:
				if velocity.length()>0:
					velocity = velocity.lerp(Vector2.ZERO, delta*decelerationRate)
					fuel-=5
		
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
	money += amount/100;
	$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)

func add_cobalt(amount):
	print("cobalt func reached")
	cobalt += amount/100;
	$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)

func add_titanium(amount):
	titanium += amount/100;
	$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
	
func add_copper(amount):
	copper += amount/100;
	$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
	
func add_iron(amount):
	iron += amount/100;
	$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)

# These are all the buttons attached to specific upgrades. When upgrades are added it
# will require a specific amount of money to purchase the item

#Oxygen Upgrades
func _on_button_2_pressed() -> void:
	print("button2 pressed")
	if (oxygenTier == 1):
		if (money >= 1 and titanium >= 1):
			oxygenTier += 1
			money -= 1
			titanium -= 1
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 2"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit3".text = "Increase Oxygen Tank Maximum.\nPrice:\n1 Gold, 5 iron"

			
	if (oxygenTier == 2):
		if (money >= 1 and iron >= 5):
			oxygenTier += 1
			money -= 1
			iron -= 50
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Money: " + str(money)
			$"../CanvasLayer/Shop/TextEdit3".text = "Increase Oxygen Tank Maximum.\nPrice:\n1 Gold, 20 Iron"
			
			
	if (oxygenTier == 3):
		if (money >= 1 and iron >= 20):
			oxygenTier += 1
			money -= 1
			iron -= 20			
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 4"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit3".text = "Increase Oxygen Tank Maximum.\nPrice:\n1 Gold, 30 Iron, 1 Titanium"
			
	if (oxygenTier == 4):
		if (money >= 1 and iron >= 30 and titanium >= 1):
			oxygenTier += 1
			money -= 1
			iron -= 30	
			titanium -= 1
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Maximum Reached"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit3".text = ""
			
#fuel upgrades
func _on_button_pressed() -> void:
	print("button1 pressed")
	if (fuelTier == 1):
		if (money >= 1 and cobalt >= 1):
			fuelTier += 1
			money -= 1
			cobalt -= 1
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 2"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum.\nPrice:\n2 Gold, 2 Cobalt"
			
	if (fuelTier == 2):
		if (money >= 2 and cobalt >= 2):
			fuelTier += 1
			money -= 2
			cobalt -= 2
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum.\nPrice:\n3 Gold, 3 Cobalt"
			
	if (fuelTier == 3):
		if (money >= 3 and cobalt >= 3):
			fuelTier += 1
			money -= 3
			cobalt -= 3
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 4"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum.\nPrice:\n4 Gold, 4 Cobalt"
			
	if (fuelTier == 4):
		if (money >= 4 and cobalt >= 4):
			fuelTier += 1
			money -= 4
			cobalt -= 4
			$"../CanvasLayer/Shop/Button".text = "Fuel Max Reached"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit".text = ""

#Thruster upgrades
func _on_button_3_pressed() -> void:
	print("button3 pressed")
	if (thrusterTier == 1):
		if (copper >= 1 and iron >= 1):
			thrusterTier += 1
			copper -= 1
			iron -= 1
			$"../CanvasLayer/Shop/Button3".text = "Thruster Tier 2"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit2".text = "Increase Thruster\nPower.\nPrice:\n2 Copper, 2 Iron"
			
	if (thrusterTier == 2):
		if (copper >= 2 and iron >= 2):
			thrusterTier += 1
			copper -= 2
			iron -= 2
			$"../CanvasLayer/Shop/Button3".text = "Thruster Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit2".text = "Increase Thruster\nPower.\nPrice:\n3 Copper, 3 Iron"
			
	if (thrusterTier == 3):
		if (copper >= 3 and iron >= 3):
			thrusterTier += 1
			money -= 3
			iron -= 3
			$"../CanvasLayer/Shop/Button3".text = "Thruster Max Reached"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit2".text = ""
