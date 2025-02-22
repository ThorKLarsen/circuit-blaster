extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = (GameData.player.stat_block.health/GameData.player.stat_block.max_health) * max_value
	print(GameData.player.stat_block.health, ' ', GameData.player.stat_block.max_health)
