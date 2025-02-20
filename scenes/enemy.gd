class_name Enemy extends CharacterBody2D

@export var attack_timer: Timer
@export var damage_timer: Timer
@export var sprite: Node2D

var stat_block: StatBlock
var outer_rect: Rect2

var stall_timer = 4.0
var stall_position = 45
var horizontal = 0

# = Stats =
@export_category("Stat modifiers")
@export var health_mod: float = 0.4
@export var regen_mod: float = 0.
@export var damage_mod: float = 1.
@export var attack_speed_mod: float = 0.7
@export var speed_mod: float = 0.7

var health:
	get(): return round(health_mod * stat_block.health)
	set(value): stat_block.health = value 
var regen:
	get(): return regen_mod * stat_block.regen
	set(value): stat_block.regen = value 
var damage:
	get(): return damage_mod * stat_block.damage
	set(value): stat_block.damage = value 
var attack_speed:
	get(): return attack_speed_mod * stat_block.attack_speed 
	set(value): stat_block.attack_speed = value
var speed:
	get(): return speed_mod * stat_block.speed
	set(value): stat_block.speed = value 


# Called when the node enters the scene tree for the first time.
func _ready():
	if stat_block == null:
		stat_block = StatBlock.make_random_enemy_from_level(GameData.level)
	
	attack_timer.wait_time = 1/attack_speed


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
		velocity = Vector2(0, 2*speed)
	elif stall_timer >= 0:
		velocity = Vector2(0, 0)
		stall_timer -= delta
	else:
		horizontal += clamp(5 - randf()*10, -10, 10)
		velocity = Vector2(horizontal, speed)
		if (position.x - Constants.left_margin) < 50:
			horizontal += 5
		if (Constants.right_margin - position.x) < 50:
			horizontal -= 5

func shoot():
	
	var bullet_velocity = 100 * global_position.direction_to(
		GameData.player_position \
		+ Vector2(1, 0)*randfn(0, 8)
	)
	
	if bullet_velocity.angle() < PI/4 or bullet_velocity.angle() > 3*PI/4:
		return
	
	BulletHandler.spawn_bullet(
		BulletHandler.BulletTypes.ENEMY_BULLET,
		position,
		bullet_velocity,
		10,
		BulletHandler.bullet_texture,
		Rect2i(16, 0, 16, 16),
	)

func hit(value):
	print(value, ' ', health)
	health -= value
	damage_timer.start(min(value, 100)/100.)
	#modulate = Color.CRIMSON
	if health <= 0:
		print('dead')
		kill()

func kill(player_kill = true):
	queue_free()

func _on_shoot_timer_timeout():
	shoot()


func _on_damage_flash_timeout():
	#modulate = Color.WHITE
	pass
