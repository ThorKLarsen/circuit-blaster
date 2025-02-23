class_name StatBlock extends Object

enum Stats{
	HEALTH,
	REGEN,
	DAMAGE,
	ATTACK_SPEED,
	ATTACK_LEVEL,
	SPEED
}

var level: int

var max_health: float
var health: float
const base_health = 50
static func per_level_health(lvl): return lvl * 10 # Average increase pr. level
var regen: float # Health pr. second
const base_regen = 0.2
static func per_level_regen(lvl): return lvl * 0.05

var damage: float
const base_damage = 10
static func per_level_damage(lvl): return lvl * 2 + lvl**2
var attack_speed: float #  attacks pr. second
const base_attack_speed = 1.
static func per_level_attack_speed(lvl): return log(1 + lvl/10.)

var attack_level: int
const base_attack_level = 0
static func per_level_attack_level(lvl): return lvl/5

var speed: float # pixels per second
const base_speed = 50

func _init(
	new_level,
	new_health,
	new_regen,
	new_damage,
	new_attack_speed,
	new_attack_level,
	new_speed,
):
	level = new_level
	max_health = new_health
	health = new_health
	regen = new_regen
	damage = new_damage
	attack_speed = new_attack_speed
	attack_level = new_attack_level
	speed = new_speed

# Adds two statblocks together.
# Health stat is not symmetic! A.add(B) had the current health of block A
func add(stat_block: StatBlock):
	max_health += stat_block.max_health
	health = health
	regen += stat_block.regen
	damage += stat_block.damage
	attack_speed += stat_block.attack_speed
	attack_level += stat_block.attack_level
	speed += stat_block.speed
	return self

func _to_string():
	var res = ""
	for key in get_stats().keys():

		if get_stats()[key] != 0:
			var n = get_stats()[key]

			res += str(key.capitalize())
			res += ": " + str(snapped(n, 0.05))
			res += "\n"

	return res

func get_stats():
	var stats = {
		"health": health,
		"regen": regen,
		"damage": damage,
		"attack_speed": attack_speed,
		"attack_level": attack_level,
		"speed": speed
	}
	return stats


static func make_random_circuit_from_level(lvl: int, size: int):
	
	# Define stats
	var health = 0
	var regen = 0
	var damage = 0
	var attack_speed = 0
	var attack_level = 0
	var speed = 0
	
	# The number of rolls (each roll can hit a different stat or the same)
	var n = 1
	for i in range(size-1):
		if randf() > 0.4:
			n += 1
	
	print(n)
	var weights = [10, 5, 10, 8, 2, 7]
	for i in range(n):
		match(Global.rand_weighted(range(Stats.size()), weights)):
			0: health += per_level_health(lvl + 2)
			1: regen += per_level_regen(lvl + 2)
			2: damage += per_level_damage(lvl + 2)
			3: attack_speed += per_level_attack_speed(lvl + 2)
			4: attack_level += 1
			5: speed += 20

	
	return StatBlock.new(lvl, health, regen, damage, attack_speed, attack_level, speed)

static func make_random_enemy_from_level(lvl: int):
	var health = base_health + randi_range(int(0.5 * per_level_health(lvl)), int(1.5 * per_level_health(lvl)))
	var regen = base_regen + randf_range(0.5 * per_level_regen(lvl), 1.5 * per_level_regen(lvl))
	regen = snapped(regen, 0.001)
	var damage = base_damage + randi_range(int(0.5 * per_level_damage(lvl)), int(1.5 * per_level_damage(lvl)))
	var attack_speed = base_attack_speed
	var attack_level = per_level_attack_level(lvl)
	if randf() > 0.97: attack_level += 1
	var speed = base_speed
	return StatBlock.new(lvl, health, regen, damage, attack_speed, attack_level, speed)

static func make_base_player():
	var health = 70
	var regen = 0.2
	var damage = 10
	var attack_speed = 2.
	var attack_level = 3
	var speed = 150.
	return StatBlock.new(1, health, regen, damage, attack_speed, attack_level, speed)


static func make_exact_from_level(lvl: int):
	var health = base_health + per_level_health(lvl)
	var regen = base_regen + per_level_regen(lvl)
	var damage = base_damage + per_level_damage(lvl)
	var attack_speed = base_attack_speed + per_level_attack_speed(lvl)
	var attack_level = per_level_attack_level(lvl)
	var speed = 75
	return StatBlock.new(lvl, health, regen, damage, attack_speed, attack_level, speed)
