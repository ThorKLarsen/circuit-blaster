class_name EnemySpawner extends Node2D

var BaseEnemy = load("res://scenes/enemy.tscn")

var spawn_lanes = 5
var lane_width = Constants.game_area_size.x - 2*Constants.SIDE_MARGIN_WIDTH

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func random_enemy_wave():
	pass

func spawn_enemy_in_lane(enemy: Node2D, lane: int):
	enemy.position = get_lane_center(lane)
	get_parent().add_child(enemy)

func get_lane_center(lane: int):
	return Vector2(Constants.SIDE_MARGIN_WIDTH + (lane+0.5)*lane_width, 0)
