class_name ShootPatternComponent extends Component

enum PatternTypes{
	Straight,
	Angled,
	Wide,
	Burst
}

@export var bullet_speed = 300
@export var bullet_type: BulletHandler.BulletTypes = BulletHandler.BulletTypes.PLAYER_BULLET
@export var forward_direction: Vector2 = Vector2(0, -1)



# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

func _shoot(position: Vector2, velocity: Vector2):
	BulletHandler.spawn_bullet(
		BulletHandler.BulletTypes.PLAYER_BULLET,
		position,
		velocity,
		agent.damage,
		load("res://assets/CB_spritesheet.png"),
		Rect2i(16, 0, 16, 16)
	)

func _shoot_from_agent(offset: Vector2, velocity: Vector2):
	BulletHandler.spawn_bullet(
		BulletHandler.BulletTypes.PLAYER_BULLET,
		agent.position + offset,
		velocity,
		agent.damage,
		load("res://assets/CB_spritesheet.png"),
		Rect2i(16, 0, 16, 16)
	)

func shoot_straight():
	_shoot(agent.global_position, forward_direction * bullet_speed)

func shoot_three_angled():
	_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(0.2))
	_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(-0.2))
	_shoot(agent.global_position, forward_direction * bullet_speed)

func shoot_three_wide():
	_shoot(agent.global_position + Vector2(10, 0), forward_direction * bullet_speed)
	_shoot(agent.global_position + Vector2(-10, 0), forward_direction * bullet_speed)
	_shoot(agent.global_position, forward_direction * bullet_speed)

func shoot_burst():
	var interval = 0.05
	for i in range(8):
		get_tree().create_timer(i*interval).timeout.connect(
			_shoot_from_agent.bind(Vector2(0, 0), forward_direction * bullet_speed)
		)

func shoot_arc_small():
	for i in range(6):
		_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(-0.25 + i*0.1))

func shoot_arc(n: int, angle: float = PI/3):
	var increment = (angle)/(n-1)
	for i in range(n):
		_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(-angle/2 + i*increment))
