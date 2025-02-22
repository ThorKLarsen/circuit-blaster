extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	shoot()


func move(delta):
	velocity = Vector2(0, stat_block.speed)

func _shoot(velocity: Vector2):
	BulletHandler.spawn_bullet(
		get_world_2d(),
		BulletHandler.BulletTypes.ENEMY_BULLET,
		global_position,
		velocity,
		10,
		BulletHandler.bullet_texture,
		Rect2i(16*4, 0, 16, 16),
		Rect2i(0, 0, 6, 6),
		false
	)

func shoot():
	var n = 7 + min(stat_block.attack_level/2, 12)
	var start_angle = -PI
	var end_angle =  PI
	
	for i in range(n):
		var angle = lerp(start_angle, end_angle, (i/float(n)))
		get_tree().create_timer(i * attack_timer.wait_time/n).timeout.connect(
			_shoot.bind(Vector2(0, 200).rotated(angle))
		)
		get_tree().create_timer(i * attack_timer.wait_time/n).timeout.connect(
			_shoot.bind(Vector2(0, 200).rotated(angle + PI))
		)
