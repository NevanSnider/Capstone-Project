extends Sprite2D

@export var player: Node2D  # Your player node (Ship)
@export var respawn_point: Marker2D  # Your RespawnPoint marker
@export var minimap_radius: float = 90.0  # Distance from minimap center to edge
@export var minimap_container: SubViewportContainer  # MinimapContainer
@export var main_camera: Camera2D

var minimap_center: Vector2

func _ready():
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
	position = minimap_center + direction_to_home * minimap_radius
	
	# Rotate arrow to point toward respawn point
	rotation = direction_to_home.angle() + PI / 2  # Adjust if needed

		
