extends Control

@onready var asteroid_slot = $Panel/VBoxContainer/GridContainer/AsteroidSlot
@onready var asteroid_count_label = $Panel/VBoxContainer/GridContainer/AsteroidSlot/Label
@onready var asteroid_sprite = $Panel/VBoxContainer/GridContainer/AsteroidSlot/TextureRect

@onready var package_slot = $Panel/VBoxContainer/GridContainer/PackageSlot
@onready var package_count_label = $Panel/VBoxContainer/GridContainer/PackageSlot/Label
@onready var package_sprite = $Panel/VBoxContainer/GridContainer/PackageSlot/TextureRect

func _ready():
	update_display()
	hide()
	GlobalSettings.inventory_changed.connect(update_display)

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		toggle_inventory()

func toggle_inventory():
	visible = !visible
	get_tree().paused = visible
	update_display()

func update_display():
	if asteroid_count_label:
		asteroid_count_label.text = str(GlobalSettings.golden_asteroids)
		asteroid_count_label.visible = GlobalSettings.golden_asteroids > 0
	
	if asteroid_sprite:
		asteroid_sprite.visible = GlobalSettings.golden_asteroids > 0
	
	if package_count_label:
		package_count_label.text = str(GlobalSettings.packages)
		package_count_label.visible = GlobalSettings.packages > 0
	
	if package_sprite:
		package_sprite.visible = GlobalSettings.packages > 0


func _on_close_pressed():
	hide()
	get_tree().paused = false
