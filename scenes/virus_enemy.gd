extends Enemy

var angle = 0
var angl_velocity = (PI*2)/3 # Radians Pr. Second
var radius = 40

var constant_speed = Vector2(0, 10)

func _ready():
	super._ready()


func move(delta):
	velocity = (radius * angl_velocity) * Vector2(cos(angle), sin(angle))
	velocity += constant_speed
	angle += angl_velocity * delta
	if angle >= 2*PI:
		angle -= 2*PI

func shoot():
	var n = 6
	for i in range(n):
		var dir = Vector2(cos((i/float(n))*PI*2), sin((i/float(n))*PI*2))
		BulletHandler.spawn_bullet(
			get_world_2d(),
			BulletHandler.BulletTypes.ENEMY_BULLET,
			global_position,
			dir * 45,
			10,
			BulletHandler.bullet_texture,
			Rect2i(16*4, 0, 16, 16),
			Rect2i(0, 0, 6, 6),
			false
		)
