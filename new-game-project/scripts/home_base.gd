extends Node
@onready var shop_node = get_node("/root/Game/CanvasLayer/Shop")

signal player_entered_base


var player_in_base = false
var save_manager: Node = null

func _ready():
	save_manager = get_tree().get_current_scene().get_node("SaveManager")
	
#When you enter the body of the home base, it updates whether you are and sends that information to the relevant places
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Ship":
		player_in_base = true
		shop_node.set_pib(true)
		save_manager.save_game(
			body.global_position,
			GameController.package_collected,
			GameController.asteroid_collected
		)
		
		emit_signal("player_entered_base")

		#Status of asteroid/package collection for save state testing
		print("asteroid collected:", GameController.asteroid_collected )
		print("package collected:", GameController.package_collected )


		
func _process(delta):
	if player_in_base and Input.is_action_just_pressed("interact"):
		if GameController.package_collected == true:
			GameController.package_return(GameController.asteroid_collected)
			print("package returned!")
