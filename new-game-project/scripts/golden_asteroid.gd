extends Node
@export var collected: bool = true
var player_in_body = false
@onready var ding: AudioStreamPlayer =  get_node("/root/Game/Ding")
@onready var tooltip = get_node("/root/Game/CanvasLayer/HoverText")
@export var asteroid_name: String = "Unknown Asteroid"

func _ready():
	add_to_group("asteroids")
	
	if not has_meta("asteroid_id"):
		set_meta("asteroid_id", get_path())
	
	var asteroid_id = get_meta("asteroid_id")
	if asteroid_id in GlobalSettings.collected_asteroid_ids:
		queue_free()


func _on_area_2d_body_entered(body):
	print("enter asteroid body")
	if body.name == "Ship":
		player_in_body = true
		
func _on_area_2d_body_exited(body):
	print("exit asteroid body")
	if body.name == "Ship":
		player_in_body = false
		

	
func _process(delta):
	if player_in_body and (AccessibilityHandler.itemPickedUpAccessibility || Input.is_action_just_pressed("interact")):
		GameController.asteroid_collect(GameController.asteroid_collected)
		print("Asteroid Collected!")
		if $Sprite2D.texture == preload("res://assets/golden_asteroid.png"):
			$"../Ship".add_money(100)
			GlobalSettings.golden_asteroids += 1
			print("Golden Asteroid Collected")
		elif $Sprite2D.texture == preload("res://assets/cobalt-asteroid.png"):
			$"../Ship".add_cobalt(100)
			GlobalSettings.cobalt_asteroids += 1
			print("Cobalt Asteroid Collected")
		elif $Sprite2D.texture == preload("res://assets/copper-asteroid.png"):
			$"../Ship".add_copper(100)
			GlobalSettings.copper_asteroids += 1
			print("Copper Asteroid Collected")
		elif $Sprite2D.texture == preload("res://assets/iron-asteroid.png"):
			$"../Ship".add_iron(100)
			GlobalSettings.iron_asteroids += 1
			print("Iron Asteroid Collected")
		elif $Sprite2D.texture == preload("res://assets/titanium-asteroid.png"):
			$"../Ship".add_titanium(100)
			GlobalSettings.titanium_asteroids += 1
			print("Titanium Asteroid Collected")
		
		
		var asteroid_id = get_meta("asteroid_id")
		if not asteroid_id in GlobalSettings.temporary_collected_ids:
			GlobalSettings.temporary_collected_ids.append(asteroid_id)
			print("Added to temporary collection: ", asteroid_id)
		
		ding.play()
		await get_tree().create_timer(0.1).timeout
		
		$Sprite2D.visible = false
		set_process(false)
		$Area2D.set_deferred("monitoring", false)
		$Area2D.input_pickable = false


func _on_area_2d_mouse_entered() -> void:
	tooltip.text = asteroid_name
	tooltip.visible = true

func _on_area_2d_mouse_exited() -> void:
	tooltip.visible = false
