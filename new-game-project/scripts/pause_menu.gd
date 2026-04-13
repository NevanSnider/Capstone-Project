extends Control

func _ready():
	visible = false

func resume():
	visible = false
	get_tree().paused = false
	
func pause():
	visible = true
	get_tree().paused = true

func testPause():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()
		

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().quit()
	


func _process(delta):
	testPause()
