extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_enemy_spawner_timeout():
	var width = get_viewport_rect().size.x
	var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf()*width/3 + width/3, -16)
	add_child(enemy)
