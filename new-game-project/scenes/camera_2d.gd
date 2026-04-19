extends Camera2D
var zoomSpeed = 5

@export var target: Node2D
var spin = false
var zoomTier = 1
var maxZoom = 1

func packageDelivered():
	zoomTier +=1
	
	#implement tiers
	if(zoomTier == 1):
		maxZoom = 1
	elif(zoomTier == 2):
		maxZoom = 0.7197
	elif(zoomTier == 3):
		maxZoom = 0.5180		
	elif(zoomTier == 4):
		maxZoom = 0.3728			
	elif(zoomTier == 5):
		maxZoom = 0.2683		
	elif(zoomTier == 6):
		maxZoom = 0.1931	
	elif(zoomTier == 7):
		maxZoom = 0.1389	
	elif(zoomTier == 8):
		maxZoom = 0.1		

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
		zoom.x = clamp(zoom.x, maxZoom, 10.0)
		zoom.y = clamp(zoom.y, maxZoom, 10.0)
