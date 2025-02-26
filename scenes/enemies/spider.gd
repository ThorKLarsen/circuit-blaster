extends Enemy

var target_pos: Vector2

var timer: float = 0
var wait: float = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

func move(delta):
	
	if timer <= 0:
		timer += wait
		var posx = (Constants.game_area_size.x - Constants.SIDE_MARGIN_WIDTH*2) * randf()
		var posy = Constants.game_area_size.y/3  * randf()
		posx += Constants.SIDE_MARGIN_WIDTH
		target_pos = Vector2(posx, posy)
		spawn_egg()

	if abs(position.distance_to(target_pos)) <= 10:
		velocity = Vector2(0, 0)
		timer -= delta
	else:
		velocity = position.direction_to(target_pos) * stat_block.speed

func shoot():
	pass

func spawn_egg():
	pass
