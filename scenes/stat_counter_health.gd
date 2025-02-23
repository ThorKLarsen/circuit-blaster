extends Label



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(snapped(GameData.player.stat_block.health, 0.05))
	text += "/" + str(snapped(GameData.player.stat_block.max_health, 0.05))
