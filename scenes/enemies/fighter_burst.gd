extends Enemy


var stall_timer = 1.5
var stall_position = 45

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


func move(delta):
	if position.y <= stall_position:
		velocity.y = 2*stat_block.speed
	elif stall_timer >= 0:
		velocity.y = 0
		stall_timer -= delta
	else:
		velocity.x += clamp(5 - randf()*10, -15, 15)
		velocity.y = stat_block.speed
	
	if (position.x - Constants.left_margin) < 16:
		velocity.x += 5
	elif (Constants.right_margin - position.x) < 16:
		velocity.x -= 5
	else:
		velocity.x -= sign(velocity.x)* 5


func shoot():
	var bullet_velocity = Vector2(0, 150)
	var n_bullets = stat_block.attack_level
	for i in range(3):
		for j in range(n_bullets):
			BulletHandler.spawn_bullet(
				get_world_2d(),
				BulletHandler.BulletTypes.ENEMY_BULLET,
				position,
				bullet_velocity.rotated((1 - i)*PI/12) * (1. + j*0.15),
				10,
				BulletHandler.bullet_texture,
				Rect2i(16, 0, 16, 16),
			)
