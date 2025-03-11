extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameData.stage == -1:
		text = "READY!"
	else:
		text = "Stage: " + str(GameData.world) + "-" + str(GameData.stage%5 + 1)
