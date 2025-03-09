class_name Enemy extends CharacterBody2D

@export var attack_timer: Timer
@export var damage_timer: Timer
@export var sprite: Node2D

var stat_block: StatBlock
var outer_rect: Rect2

# = Stats =
@export_category("Stat modifiers")
@export var health_mod: float = 1.
@export var regen_mod: float = 0.
@export var damage_mod: float = 1.
@export var attack_speed_mod: float = 0.7
@export var speed_mod: float = 0.7

@export_category("Misc Data")
@export var threat = 1

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
	attack_timer.stop()
	attack_timer.start()


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
	pass

func shoot():
	pass

func hit(value):
	stat_block.health -= value
	damage_timer.start(min(value, 50.)/100.)
	#modulate = Color.CRIMSON
	if stat_block.health <= 0:
		kill()

func kill(player_kill = true):
	stat_block.free.call_deferred()
	queue_free()
	

func _on_shoot_timer_timeout():
	shoot()


func _on_damage_flash_timeout():
	#modulate = Color.WHITE
	pass
