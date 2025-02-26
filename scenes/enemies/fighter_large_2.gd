extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


func move(delta):
	if position.y < 50:
		velocity = Vector2(0, stat_block.speed)
	else:
		velocity = Vector2(0, 0)

func shoot():
	var dir = position.direction_to(GameData.player_position)
	for i in range(9):
		_shoot(dir.rotated(0.2) * (150 - i*7))
		_shoot(dir.rotated(-0.2) * (150 - i*7))



func _shoot(velocity: Vector2):
	BulletHandler.spawn_bullet(
		get_world_2d(),
		BulletHandler.BulletTypes.ENEMY_BULLET,
		global_position,
		velocity,
		stat_block.damage,
		BulletHandler.bullet_texture,
		Rect2i(16*4, 0, 16, 16),
		Rect2i(0, 0, 6, 6),
		false
	)
