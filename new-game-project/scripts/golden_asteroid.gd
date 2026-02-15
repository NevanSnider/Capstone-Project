extends Node
@export var collected: bool = true
var player_in_body = false
@onready var ding: AudioStreamPlayer =  get_node("/root/Game/Package/Ding")


func _ready():
	print(get_node_or_null("/root/Game/Package/Ding"))


func _on_area_2d_body_entered(body):
	if body.name == "Ship":
		player_in_body = true
		
func _on_area_2d_body_exited(body):
	if body.name == "Ship":
		player_in_body = false
	
func _process(delta):
	if player_in_body and Input.is_action_just_pressed("interact"):
		GameController.asteroid_collect(GameController.asteroid_collected)
		print("Asteroid Collected!")
		$"../../Ship".add_money(100)
		ding.play()
		await get_tree().create_timer(0.1).timeout
		queue_free()
