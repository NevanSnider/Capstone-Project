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

var player_in_base = false

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
	player_in_base = true
	fuel = maxFuel
	oxygen = maxOxygen
	if(not(Input.is_action_pressed("turn_left")) and not(Input.is_action_pressed("turn_right")) and not(Input.is_action_pressed("thrust"))):
		velocity = velocity *0.9
		rotateSpeed = rotateSpeed * 0.9

	

func _ready():
	var save_data = SaveManager.load_game()
	if save_data and not save_data.is_empty():
		SaveManager.apply_save_data(save_data)
	
	var home_base = get_tree().get_current_scene().get_node("HomeBase")
	home_base.player_entered_base.connect(_on_player_entered_base)
	
	
	# Attempt to connect to the WebSocket server
	var err = _ws_client.connect_to_url(server_url)
	if err != OK:
		print("Error connecting to server.")
	else:
		print("Connection initiated.")
		_is_connected=true
		
	#set oxygen price
	$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 2"
	$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
	$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
	$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
	$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
	$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
	$"../CanvasLayer/Shop/TextEdit3".text = "Increase Oxygen Tank Maximum.\nPrice:\n5 iron"
		
	#set fuel price	
	$"../CanvasLayer/Shop/Button".text = "Fuel Tier 2"
	$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum.\nPrice:\n10 Iron, 3 Cobalt"
					
	$"../CanvasLayer/Shop/Button3".text = "Thruster Tier 2"
	$"../CanvasLayer/Shop/TextEdit2".text = "Increase Thruster\nPower.\nPrice:\n20 Iron, 10 Copper"
					

func _input(event):
	if event.is_action_pressed("reset_game"):
		if player_in_base:
			SaveManager.reset_all_progress()
		else:
			print("Must be at base to reset progress")
	
func _handle_command(packet:String):
	print(packet)
	#respawn function
func respawn_to_base():
	print("Died! Respawning temporarily collected asteroids...")
	
	var all_asteroids = get_tree().get_nodes_in_group("asteroids")
	for asteroid in all_asteroids:
		if asteroid.has_meta("asteroid_id"):
			var id = asteroid.get_meta("asteroid_id")
			if id in GlobalSettings.temporary_collected_ids:
				print("Respawning asteroid: ", id)
				asteroid.get_node("Sprite2D").visible = true
				asteroid.set_process(true)
				asteroid.get_node("Area2D").monitoring = true
	
	GlobalSettings.temporary_collected_ids.clear()
	GlobalSettings.golden_asteroids = 0
	GlobalSettings.packages = 0
	
	var save_data = SaveManager.load_game()
	if save_data and not save_data.is_empty():
		SaveManager.apply_save_data(save_data)
	
	global_position = respawn_point.global_position
	velocity = Vector2.ZERO
	rotateSpeed = 0
	rotation = 0

func respawn_asteroid(asteroid_path: String):
	var generation_script = get_tree().get_current_scene().get_node("All Rocks")
	if not generation_script:
		print("Could not find generation script")
		return
	
	var asteroid_parts = asteroid_path.split("/")
	var asteroid_name = asteroid_parts[-1]
	
	print("Respawning asteroid: ", asteroid_name, " at path: ", asteroid_path)
	
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
		maxOxygen = 40000
	elif(oxygenTier == 2):
		maxOxygen = 80000
	elif(oxygenTier == 3):
		maxOxygen = 150000		
	elif(oxygenTier == 4):
		maxOxygen = 250000	
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
		add_money(100)
		add_iron(100)
		add_cobalt(100)
		add_copper(100)
		add_titanium(100)
		
		
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
		if (money >= 0 and iron >= 5):
			oxygenTier += 1
			money -= 0
			iron -= 5
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit3".text = "Increase Oxygen Tank Maximum.\nPrice:\n20 iron"
	
		

			
	elif (oxygenTier == 2):
		if (money >= 0 and iron >= 20):
			oxygenTier += 1
			money -= 0
			iron -= 20
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 4"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit3".text = "Increase Oxygen Tank Maximum.\nPrice:\n30 Iron, 1 Titanium"
			
			
	elif (oxygenTier == 3):
		if (money >= 0 and iron >= 30 and titanium >= 1):
			oxygenTier += 1
			money -= 0
			iron -= 30		
			titanium -= 1					
			$"../CanvasLayer/Shop/Button2".text = "Oxygen Tier 5"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit3".text = "Increase Oxygen Tank Maximum.\nPrice:\n100 Iron, 5 Titanium"
			
	elif (oxygenTier == 4):
		if (money >= 0 and iron >= 100 and titanium >= 5):
			oxygenTier += 1
			money -= 0
			iron -= 100	
			titanium -= 5
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
		if (money >= 0 and iron >= 10 and cobalt >= 3 and titanium >= 0):
			fuelTier += 1
			money -= 0
			iron -= 10
			cobalt -= 3
			titanium -= 0
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum.\nPrice:\n15 Iron, 10 Cobalt, 2 Titanium"
			
	if (fuelTier == 2):
		if (money >= 0 and iron >= 15 and cobalt >= 10 and titanium >= 2):
			fuelTier += 1
			money -= 0
			iron -= 15	
			cobalt -= 10
			titanium -= 2	
			$"../CanvasLayer/Shop/Button".text = "Fuel Tier 4"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit".text = "Increase Fuel Tank\nMaximum.\nPrice:\n50 Iron, 25 Cobalt, 5 Titanium"
			
	if (fuelTier == 3):
		if (money >= 0 and iron >= 50 and cobalt >= 25 and titanium >= 5):
			fuelTier += 1
			money -= 0
			iron -= 50
			cobalt -= 25
			titanium -= 5	
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
		if (copper >= 10 and iron >= 20):
			thrusterTier += 1
			copper -= 10
			iron -= 20
			$"../CanvasLayer/Shop/Button3".text = "Thruster Tier 3"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit2".text = "Increase Thruster\nPower.\nPrice:\n50 Iron, 50 Copper, 10 Titanium"
			
	if (thrusterTier == 2):
		if (copper >= 50 and iron >= 50 and titanium >= 10):
			thrusterTier += 1
			copper -= 50
			iron -= 50
			titanium -= 50
			$"../CanvasLayer/Shop/Button3".text = "Thruster Max Reached"
			$"../CanvasLayer/Shop/TextEdit5".text = "Gold: " + str(money)
			$"../CanvasLayer/Shop/TextEdit6".text = "Cobalt: " + str(cobalt)
			$"../CanvasLayer/Shop/TextEdit7".text = "Titanium: " + str(titanium)
			$"../CanvasLayer/Shop/TextEdit8".text = "Copper: " + str(copper)
			$"../CanvasLayer/Shop/TextEdit9".text = "Iron: " + str(iron)
			$"../CanvasLayer/Shop/TextEdit2".text = ""
