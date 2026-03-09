extends CanvasLayer

@onready var task_list_container = $Panel/VBoxContainer/TaskScrollContainer/TaskListContainer

func _ready():
	layer = 10
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	TaskManager.tasks_updated.connect(update_task_list)

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		toggle_task_log()

func toggle_task_log():
	visible = !visible
	get_tree().paused = visible
	if visible:
		update_task_list()

func update_task_list():
	print("Updating task list...")
	print("Active tasks count: ", TaskManager.active_tasks.size())
	
	for child in task_list_container.get_children():
		child.queue_free()
	
	if TaskManager.active_tasks.size() == 0:
		var no_tasks_label = Label.new()
		no_tasks_label.text = "No active tasks"
		no_tasks_label.add_theme_color_override("font_color", Color("#004d00"))
		task_list_container.add_child(no_tasks_label)
	else:
		for task in TaskManager.active_tasks:
			print("Creating entry for task: ", task.title)
			var task_panel = create_task_entry(task)
			task_list_container.add_child(task_panel)

func create_task_entry(task: TaskManager.Task) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 80)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)
	
	vbox.anchor_left = 0
	vbox.anchor_top = 0
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	vbox.offset_left = 10
	vbox.offset_top = 10
	vbox.offset_right = -10
	vbox.offset_bottom = -10
	
	var title_label = Label.new()
	title_label.text = task.title
	title_label.add_theme_color_override("font_color", Color("#004d00"))
	vbox.add_child(title_label)
	
	var desc_label = Label.new()
	desc_label.text = task.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_color_override("font_color", Color("#004d00"))
	vbox.add_child(desc_label)
	
	var progress_label = Label.new()
	progress_label.text = TaskManager.get_task_progress(task)
	progress_label.add_theme_color_override("font_color", Color("#004d00"))
	vbox.add_child(progress_label)
	
	return panel

func _on_close_button_pressed():
	hide()
	get_tree().paused = false
