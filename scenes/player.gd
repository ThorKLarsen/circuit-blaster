extends CharacterBody2D

enum AttackModes{
	Straight,
	Wide,
	Burst
}

var BH = BulletHandler
@export var game: Game
@export var shoot_pattern_component: ShootPatternComponent
@export var sprite: AnimatedSprite2D

var stat_block: StatBlock


var attack_mode: AttackModes = AttackModes.Straight
var attack_timer = 0

func _ready():
	GameData.player = self
	sprite.play("fly")
	sprite.frame_progress = 0.5
	sprite.frame = 3
	
	stat_block = StatBlock.make_base_player()
	SignalBus.world_advanced.connect(heal.unbind(1))

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_h = Input.get_axis("move_left", "move_right")
	var direction_v = Input.get_axis("move_up", "move_down")
	var direction = Vector2(direction_h, direction_v).normalized()
	var cur_speed = stat_block.speed
	if Input.is_action_pressed("focus"):
		cur_speed = 100

	
	if Input.is_action_just_pressed("next_attack_mode"):
		attack_mode += 1
		if attack_mode > 2:
			attack_mode = 0
		SignalBus.attack_mode_changed.emit(attack_mode)
	
	if direction:
		velocity = direction * cur_speed
	else:
		velocity = velocity.move_toward(Vector2(0, 0), stat_block.speed)


	if attack_timer >= 0:
		attack_timer -= delta
	else:
		if Input.is_action_pressed("shoot"):
			$ShootAudio.play(      )
			if attack_mode == AttackModes.Straight:
				attack_timer += 1/stat_block.attack_speed
				shoot_pattern_component.shoot_straight(stat_block.attack_level)
			elif attack_mode == AttackModes.Wide:
				attack_timer += 1/stat_block.attack_speed
				shoot_pattern_component.shoot_wide(stat_block.attack_level)
			elif attack_mode == AttackModes.Burst:
				attack_timer += 1
				shoot_pattern_component.shoot_burst(stat_block.attack_level, stat_block.attack_speed)
			
		else:
			attack_timer = 0

	set_animation(delta)
	move_and_slide()
	#GameData.player_position = position
	
	if game != null:
		if game.game_state == game.GameState.Stage:
			if stat_block.health <= stat_block.max_health:
				stat_block.health += stat_block.regen * delta

func set_animation(delta):
	if sign(velocity.x) == 1:
		sprite.frame_progress -= delta * 50
	elif sign(velocity.x) == -1:
		sprite.frame_progress += delta * 50
	else:
		if sprite.frame > 3:
			sprite.frame_progress -= delta * 10
		elif sprite.frame < 3:
			sprite.frame_progress += delta * 10
		else:
			sprite.frame_progress = 0.5
			pass
	#
	if sprite.frame_progress < 0:
		sprite.frame -= 1
		sprite.frame_progress = 1
	elif sprite.frame_progress > 1:
		sprite.frame += 1
	

func spawn_bullet(
	bullet_velocity: Vector2,
	damage: float,
	offset: Vector2 = Vector2(-8, -8)
):
	BH.spawn_bullet(
		get_world_2d(),
		BH.BulletTypes.PLAYER_BULLET,
		position,
		bullet_velocity,
		damage,
		load("res://assets/CB_spritesheet.png"),
		Rect2i(16, 0, 16, 16)
	)

func hit(value):
	$HitAudio.play()
	stat_block.health -= value
	if stat_block.health < 0:
		SignalBus.player_died.emit()


func update_stats(circuits: Array[Circuit]):
	var cur_health = stat_block.health
	stat_block = StatBlock.make_base_player()
	for c in circuits:
		stat_block.add(c.stat_increases, c.active_connections + 1)
	stat_block.health = min(cur_health, stat_block.max_health)

func get_damage() -> float:
	if attack_mode == AttackModes.Straight:
		return stat_block.damage
	elif attack_mode == AttackModes.Wide:
		return stat_block.damage*0.7
	elif attack_mode == AttackModes.Burst:
		return stat_block.damage*1.2
	return 0

func heal(value: float = -1):
	if value < 0:
		stat_block.health = stat_block.max_health
	else:
		stat_block.health = clamp(stat_block.health + value, 0, stat_block.max_health)
