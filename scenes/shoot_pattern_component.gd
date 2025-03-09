class_name ShootPatternComponent extends Component

enum PatternTypes{
	Straight,
	Angled,
	Wide,
	Burst
}

@export var bullet_speed: float = 500
@export var bullet_type: BulletHandler.BulletTypes = BulletHandler.BulletTypes.PLAYER_BULLET
@export var forward_direction: Vector2 = Vector2(0, -1)



# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

func shoot_straight(attack_level: int):
	
	if attack_level > 16:
		attack_level = 16

	if attack_level % 2 == 1:
		attack_level += 1
		attack_level /= 2
		_shoot_from_agent(Vector2(0, 0), Vector2(0, -bullet_speed))
		for i in range(1, min(attack_level, 4)):
			_shoot_from_agent(Vector2(i*5, i*4), Vector2(0, -bullet_speed))
			_shoot_from_agent(Vector2(-i*5, i*4), Vector2(0, -bullet_speed))
		if attack_level > 3:
			attack_level -= 3
			for i in range(1, min(attack_level, 5)):
				_shoot_from_agent(Vector2(i*5 + 32, i*4), Vector2(0, -bullet_speed))
				_shoot_from_agent(Vector2(-i*5 - 32, i*4), Vector2(0, -bullet_speed))

	else:
		attack_level /= 2
		for i in range(0, min(attack_level, 4)):
			_shoot_from_agent(Vector2(i*5 + 2, i*4), Vector2(0, -bullet_speed))
			_shoot_from_agent(Vector2(-i*5 - 2, i*4), Vector2(0, -bullet_speed))
		if attack_level > 3:
			attack_level -= 3
			for i in range(1, min(attack_level, 5)):
				_shoot_from_agent(Vector2(i*5 + 32, i*4), Vector2(0, -bullet_speed))
				_shoot_from_agent(Vector2(-i*5 - 32, i*4), Vector2(0, -bullet_speed))

func shoot_wide(attack_level: int):
	var lifetime = 0.35
	var even = attack_level % 2
	var i = 1
	var angle = 0.15 - attack_level * 0.005
	if attack_level % 2 == 1:
		_shoot_from_agent(Vector2(0, 0), Vector2(0, -bullet_speed).rotated(angle/2.), lifetime)
		_shoot_from_agent(Vector2(0, 0), Vector2(0, -bullet_speed).rotated(-angle/2.), lifetime)
		attack_level -= 1
	else:
		_shoot_from_agent(Vector2(0, 0), Vector2(0, -bullet_speed), lifetime)
		_shoot_from_agent(Vector2(0, 0), Vector2(0, -bullet_speed).rotated(angle), lifetime)
		_shoot_from_agent(Vector2(0, 0), Vector2(0, -bullet_speed).rotated(-angle), lifetime)
		attack_level -= 2
		i += 1
	
	while attack_level > 0:
		_shoot_from_agent(
			Vector2(0, 0), 
			Vector2(0, -bullet_speed).rotated(angle/2. * int(even) + angle * i),
			lifetime
		)
		_shoot_from_agent(
			Vector2(0, 0),
			Vector2(0, -bullet_speed).rotated(-angle/2. * int(even) + -angle * i),
			lifetime
		)
		attack_level -= 2
		i += 1                 
		
	
	

func shoot_burst(attack_level: int, attack_speed: float):
	var interval = 0.06
	var i = 0
	attack_speed *= 0.85
	while attack_speed > 0:
		if attack_speed > 1:
			get_tree().create_timer(interval * i).timeout.connect(
				shoot_straight.bind((attack_level))
			)
		else:
			get_tree().create_timer(interval * i).timeout.connect(
				shoot_straight.bind(round(attack_level * attack_speed))
			)
		i += 1
		attack_speed -= 1.0



func _shoot(position: Vector2, velocity: Vector2):
	BulletHandler.spawn_bullet(
		agent.get_world_2d(),
		BulletHandler.BulletTypes.PLAYER_BULLET,
		position,
		velocity,
		agent.get_damage(),
		load("res://assets/CB_spritesheet.png"),
		Rect2i(16, 0, 16, 16)
	)

func _shoot_from_agent(offset: Vector2, velocity: Vector2, lifetime = 20):
	BulletHandler.spawn_bullet(
		agent.get_world_2d(),
		BulletHandler.BulletTypes.PLAYER_BULLET,
		agent.position + offset,
		velocity,
		agent.get_damage(),
		load("res://assets/CB_spritesheet.png"),
		Rect2i(16, 0, 16, 16),
		Rect2(0, 0, 4, 10),
		true,
		lifetime,
	)



func shoot_straight_simple():
	_shoot(agent.global_position, forward_direction * bullet_speed)

func shoot_three_angled():
	_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(0.2))
	_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(-0.2))
	_shoot(agent.global_position, forward_direction * bullet_speed)

func shoot_three_wide():
	_shoot(agent.global_position + Vector2(10, 0), forward_direction * bullet_speed)
	_shoot(agent.global_position + Vector2(-10, 0), forward_direction * bullet_speed)
	_shoot(agent.global_position, forward_direction * bullet_speed)

#func shoot_burst():
	#var interval = 0.05
	#for i in range(8):
		#get_tree().create_timer(i*interval).timeout.connect(
			#_shoot_from_agent.bind(Vector2(0, 0), forward_direction * bullet_speed)
		#)

func shoot_arc_small():
	for i in range(6):
		_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(-0.25 + i*0.1))

func shoot_arc(n: int, angle: float = PI/3):
	var increment = (angle)/(n-1)
	for i in range(n):
		_shoot(agent.global_position, (forward_direction * bullet_speed).rotated(-angle/2 + i*increment))
