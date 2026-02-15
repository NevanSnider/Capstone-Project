extends ProgressBar

@export var player: CharacterBody2D



func _process(delta):
	max_value  = player.maxOxygen


	self.value = player.oxygen
	
	if float(player.oxygen) / player.maxOxygen < .10:
		self.modulate = Color(1.0, 0.0, 0.0, 1.0)
	elif float(player.oxygen) / player.maxOxygen < .25:
		self.modulate = Color(0.906, 0.455, 0.0, 1.0)		
	elif float(player.oxygen) / player.maxOxygen < .5:
		self.modulate = Color(0.8, 0.8, 0.0, 1.0)				
	else:
		self.modulate = Color(0.0, 1.0, 0.0, 1.0)
		
	#print(self.value)
