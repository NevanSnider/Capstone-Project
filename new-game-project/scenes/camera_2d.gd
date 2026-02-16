extends Camera2D
var zoomSpeed = 5

@export var target: Node2D
var spin = false

func _process(delta):
	spin = GlobalSettings.camera_lock

	if target:
		position = target.global_position

		if spin:
			rotation = target.rotation

	
	
	var zoomDirection = 1
	if Input.is_action_just_pressed("zoom_in"):
		zoomDirection = 1.01
	elif Input.is_action_just_pressed("zoom_out"):
		zoomDirection = 0.9900990099
	
	if zoomDirection != 1:
		zoom = zoom * Vector2.ONE * ( pow(zoomDirection, zoomSpeed) )
		zoom.x = clamp(zoom.x, 0.1, 20.0)
		zoom.y = clamp(zoom.y, 0.1, 20.0)
