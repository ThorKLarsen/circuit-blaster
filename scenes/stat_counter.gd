extends Label

@export var stat: String = "regen"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(GameData.player.stat_block.get_stats()[stat])
