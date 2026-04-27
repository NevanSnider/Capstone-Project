extends Sprite2D
@export var player: Node2D
@export var minimap_radius: float = 90.0
@export var minimap_container: SubViewportContainer
@export var main_camera: Camera2D

var minimap_center: Vector2
var base_position: Vector2
var tracking_enabled: bool = false

func _ready():
	visible = false 
	
	EventController.connect("package_collected", Callable(self, "_on_package_collected"))
	
	var task_manager = get_node("/root/TaskManager")
	task_manager.quest_accepted.connect(_on_quest_accepted)
	task_manager.quest_completed.connect(_on_quest_completed)
	
	if minimap_container:
		minimap_center = minimap_container.size / 2.0
	else:
		minimap_center = Vector2(100, 100)
	
	var home_base = get_node_or_null("/root/Game/HomeBase")
	if home_base:
		base_position = home_base.global_position
		
func _process(_delta):
	if not player:
		return
	
	if not tracking_enabled:
		return
	
	var closest_package = get_closest_package_to_base()
	if not closest_package:
		visible = false
		return
	
	var direction_to_package = (closest_package.global_position - player.global_position)
	
	if direction_to_package.length() > 0:
		direction_to_package = direction_to_package.normalized()
		
	if main_camera and main_camera.spin == true:
		direction_to_package = direction_to_package.rotated(-player.global_rotation)
	
	position = minimap_center + direction_to_package * (minimap_radius - 15)
	rotation = direction_to_package.angle() + PI / 2

func get_closest_package_to_base() -> Node2D:
	var home_base = get_node_or_null("/root/Game/HomeBase")
	if not home_base:
		return null
	
	var packages = get_tree().get_nodes_in_group("packages")
	var closest_package = null
	var closest_distance = INF
	
	for package in packages:
		var distance = home_base.global_position.distance_to(package.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_package = package
	
	return closest_package
	
func _on_package_collected():
	pass

func _on_quest_accepted(_quest_id: String):
	tracking_enabled = true
	visible = true

func _on_quest_completed(_quest_id: String):
	if TaskManager.active_quests.is_empty():
		tracking_enabled = false
		visible = false
