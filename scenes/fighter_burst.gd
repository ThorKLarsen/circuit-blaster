extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


func move(delta):
	super.move(delta)


func shoot():
	var bullet_velocity = Vector2(0, 150)
	for i in range(3):
		for j in range(3):
			BulletHandler.spawn_bullet(
				BulletHandler.BulletTypes.ENEMY_BULLET,
				position,
				bullet_velocity.rotated((1 - i)*PI/12) * (1. + j*0.15),
				10,
				BulletHandler.bullet_texture,
				Rect2i(16, 0, 16, 16),
			)
