extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	GameData.stage = -1
	var game_scene = load("res://scenes/game.tscn")
	get_tree().change_scene_to_packed(game_scene)
