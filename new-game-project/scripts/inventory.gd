extends Control

@onready var asteroid_slot = $Panel/VBoxContainer/GridContainer/AsteroidSlot
@onready var asteroid_count_label = $Panel/VBoxContainer/GridContainer/AsteroidSlot/Label
@onready var asteroid_sprite = $Panel/VBoxContainer/GridContainer/AsteroidSlot/TextureRect

@onready var cobalt_slot = $Panel/VBoxContainer/GridContainer/CobaltSlot
@onready var cobalt_count_label = $Panel/VBoxContainer/GridContainer/CobaltSlot/Label
@onready var cobalt_sprite = $Panel/VBoxContainer/GridContainer/CobaltSlot/TextureRect

@onready var copper_slot = $Panel/VBoxContainer/GridContainer/CopperSlot
@onready var copper_count_label = $Panel/VBoxContainer/GridContainer/CopperSlot/Label
@onready var copper_sprite = $Panel/VBoxContainer/GridContainer/CopperSlot/TextureRect

@onready var iron_slot = $Panel/VBoxContainer/GridContainer/IronSlot
@onready var iron_count_label = $Panel/VBoxContainer/GridContainer/IronSlot/Label
@onready var iron_sprite = $Panel/VBoxContainer/GridContainer/IronSlot/TextureRect

@onready var titanium_slot = $Panel/VBoxContainer/GridContainer/TitaniumSlot
@onready var titanium_count_label = $Panel/VBoxContainer/GridContainer/TitaniumSlot/Label
@onready var titanium_sprite = $Panel/VBoxContainer/GridContainer/TitaniumSlot/TextureRect

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
		
	if cobalt_count_label:
		cobalt_count_label.text = str(GlobalSettings.cobalt_asteroids)
		cobalt_count_label.visible = GlobalSettings.cobalt_asteroids > 0
	
	if cobalt_sprite:
		cobalt_sprite.visible = GlobalSettings.cobalt_asteroids > 0
		
	if copper_count_label:
		copper_count_label.text = str(GlobalSettings.copper_asteroids)
		copper_count_label.visible = GlobalSettings.copper_asteroids > 0
	
	if copper_sprite:
		copper_sprite.visible = GlobalSettings.copper_asteroids > 0
		
	if iron_count_label:
		iron_count_label.text = str(GlobalSettings.iron_asteroids)
		iron_count_label.visible = GlobalSettings.iron_asteroids > 0
	
	if iron_sprite:
		iron_sprite.visible = GlobalSettings.iron_asteroids > 0
		
	if titanium_count_label:
		titanium_count_label.text = str(GlobalSettings.titanium_asteroids)
		titanium_count_label.visible = GlobalSettings.titanium_asteroids > 0
	
	if titanium_sprite:
		titanium_sprite.visible = GlobalSettings.titanium_asteroids > 0
	
	if package_count_label:
		package_count_label.text = str(GlobalSettings.packages)
		package_count_label.visible = GlobalSettings.packages > 0
	
	if package_sprite:
		package_sprite.visible = GlobalSettings.packages > 0


func _on_close_pressed():
	hide()
	get_tree().paused = false
