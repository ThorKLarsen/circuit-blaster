extends CharacterBody2D

var BH = BulletHandler
@export var shoot_pattern_component: ShootPatternComponent

var speed = 150
var speed_forward = speed/4.
var speed_backward = speed

var damage = 10
var attack_speed = 1.8
var attack_timer = 0

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_h = Input.get_axis("move_left", "move_right")
	if direction_h:
		velocity.x = direction_h * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	var direction_v = Input.get_axis("move_up", "move_down")
	if direction_v:
		if direction_v > 0:
			velocity.y = direction_v * speed_backward
		else:
			velocity.y = direction_v * speed_forward
	else:
		velocity.y = move_toward(velocity.y, 0, speed)

	if attack_timer >= 0:
		attack_timer -= delta
	else:
		if Input.is_action_pressed("shoot"):
			attack_timer += 1/attack_speed
			shoot_pattern_component.shoot_arc(5)
		else:
			attack_timer = 0

	move_and_slide()
	GameData.player_position = position

func spawn_bullet(
	bullet_velocity: Vector2,
	damage: float,
	offset: Vector2 = Vector2(-8, -8)
):
	BH.spawn_bullet(
		BH.BulletTypes.PLAYER_BULLET,
		position,
		bullet_velocity,
		damage,
		load("res://assets/CB_spritesheet.png"),
		Rect2i(16, 0, 16, 16)
	)

func hit(value):
	print(value)
