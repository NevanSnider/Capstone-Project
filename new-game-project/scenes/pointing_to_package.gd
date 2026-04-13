extends Sprite2D

@export var player: Node2D  # Your player node (Ship)
@export var respawn_point: Package  # Your RespawnPoint marker
@export var minimap_radius: float = 90.0  # Distance from minimap center to edge
@export var minimap_container: SubViewportContainer  # MinimapContainer
@export var main_camera: Camera2D


var minimap_center: Vector2

func _ready():
	visible = false 
	
	EventController.connect("package_collected", Callable(self, "_on_package_collected"))
	
	var package_node = get_parent().get_parent().get_parent().get_node("Package")
	package_node.package_triggered.connect(_on_package_triggered)
	
	var task_manager = get_node("/root/TaskManager")
	task_manager.task_accepted.connect(_on_task_accepted)
	task_manager.task_completed.connect(_on_task_completed)
	
	if minimap_container:
		minimap_center = minimap_container.size / 2.0
	else:
		minimap_center = Vector2(100, 100)
		
func _process(_delta):
	if not player or not respawn_point:
		return
	
	# Calculate direction from player to respawn point
	var direction_to_home = (respawn_point.global_position - player.global_position)
	
	# Normalize the direction
	if direction_to_home.length() > 0:
		direction_to_home = direction_to_home.normalized()
		
	if (main_camera.spin == true):
		direction_to_home = direction_to_home.rotated(-player.global_rotation)
	
	# INSTANTLY position arrow on the edge of the minimap
	position = minimap_center + direction_to_home * (minimap_radius - 15)
	
	# Rotate arrow to point toward respawn point
	rotation = direction_to_home.angle() + PI / 2  # Adjust if needed
	
func _on_package_triggered():
	queue_free()

func _on_task_accepted(task_id: String):
	if task_id == "collect_packages_1":
		visible = true

func _on_task_completed(task_id: String):
	if task_id == "collect_packages_1":
		queue_free()
