class_name Enemy extends CharacterBody2D

@export var attack_timer: Timer
@export var damage_timer: Timer
@export var sprite: Node2D

var stat_block: StatBlock
var outer_rect: Rect2

var stall_timer = 1.5
var stall_position = 45

# = Stats =
@export_category("Stat modifiers")
@export var health_mod: float = 0.4
@export var regen_mod: float = 0.
@export var damage_mod: float = 1.
@export var attack_speed_mod: float = 0.7
@export var speed_mod: float = 0.7


# Called when the node enters the scene tree for the first time.
func _ready():
	if stat_block == null:
		stat_block = StatBlock.make_random_enemy_from_level(GameData.stage)
	
	stat_block.health *= health_mod
	stat_block.regen *= regen_mod
	stat_block.damage *= damage_mod
	stat_block.attack_speed *= attack_speed_mod
	stat_block.speed *= speed_mod
	
	attack_timer.wait_time = 1/stat_block.attack_speed


func _process(delta):
	if !damage_timer.is_stopped():
		modulate = Color.WHITE.lerp(Color.CRIMSON, damage_timer.time_left*10)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move(delta)
	move_and_slide()
	
	#health += regen * delta

func initialize(new_stat_block: StatBlock):
	stat_block = new_stat_block


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
	
	var bullet_velocity = 100 * global_position.direction_to(
		GameData.player_position \
		+ Vector2(1, 0)*randfn(0, 8)
	)
	
	if bullet_velocity.angle() < PI/4 or bullet_velocity.angle() > 3*PI/4:
		return
	
	BulletHandler.spawn_bullet(
		get_world_2d(),
		BulletHandler.BulletTypes.ENEMY_BULLET,
		position,
		bullet_velocity,
		10,
		BulletHandler.bullet_texture,
		Rect2i(16, 0, 16, 16),
	)

func hit(value):
	stat_block.health -= value
	damage_timer.start(min(value, 100)/100.)
	#modulate = Color.CRIMSON
	if stat_block.health <= 0:
		print('dead')
		kill()

func kill(player_kill = true):
	stat_block.free.call_deferred()
	queue_free()
	

func _on_shoot_timer_timeout():
	shoot()


func _on_damage_flash_timeout():
	#modulate = Color.WHITE
	pass
