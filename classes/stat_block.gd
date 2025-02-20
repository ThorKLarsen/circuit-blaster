class_name StatBlock extends Object

var health: int
const base_health = 50
static func per_level_health(lvl): return lvl * 10 # Average increase pr. level
var regen: float # Health pr. second
const base_regen = 0.2
static func per_level_regen(lvl): return lvl * 0.05

var damage: int
const base_damage = 10
static func per_level_damage(lvl): return lvl * 2 + lvl**2
var attack_speed: float #  attacks pr. second
const base_attack_speed = 1.
static func per_level_attack_speed(lvl): return log(1 + lvl/10.)

var attack_type: int
const base_attack_type = 0
var attack_level: int
const base_attack_level = 0
static func per_level_attack_level(lvl): return lvl/5

var speed: float # pixels per second
const base_speed = 75

func _init(
	new_health,
	new_regen,
	new_damage,
	new_attack_speed,
	new_attack_type,
	new_attack_level,
	new_speed,
):
	health = new_health
	regen = new_regen
	damage = new_damage
	attack_speed = new_attack_speed
	attack_type = new_attack_type
	attack_level = new_attack_level
	speed = new_speed

func add(stat_block: StatBlock):
	health += stat_block.health
	regen += stat_block.regen
	damage += stat_block.damage
	attack_speed *= stat_block.attack_speed
	attack_type = max(attack_type, stat_block.attack_type)
	attack_level += stat_block.attack_level
	speed *= stat_block.speed
	return self

func _to_string():
	var res = ""
	for key in get_stats().keys():
		if get_stats()[key] != 0:
			var n = get_stats()[key]

			res += str(key.capitalize())
			res += ": " + str(get_stats()[key])
			res += "\n"
	return res

func get_stats():
	var stats = {
		"health": health,
		"regen": regen,
		"damage": damage,
		"attack_speed": attack_speed,
		"attack_type": attack_type,
		"attack_level": attack_level,
		"speed": speed
	}
	return stats

static func make_random_circuit_from_level(lvl: int):
	var health = randi_range(int(0.5 * per_level_health(lvl)), int(1.5 * per_level_health(lvl)))
	var regen = randf_range(0.5 * per_level_regen(lvl), 1.5 * per_level_regen(lvl))
	regen = snapped(regen, 0.001)
	var damage = randi_range(int(0.5 * per_level_damage(lvl)), int(1.5 * per_level_damage(lvl)))
	var attack_speed = randf_range(0.8 * per_level_attack_speed(lvl), 1.2*per_level_attack_speed(lvl))
	attack_speed = snapped(attack_speed, 0.001)
	var attack_type = 0
	var attack_level = 0
	if randf() > 0.93: attack_level += 1
	var speed = randf_range(50, 100)
	speed = snapped(speed, 0.01)
	return StatBlock.new(health, regen, damage, attack_speed, attack_type, attack_level, speed)

static func make_random_enemy_from_level(lvl: int):
	var health = base_health + randi_range(int(0.5 * per_level_health(lvl)), int(1.5 * per_level_health(lvl)))
	var regen = base_regen + randf_range(0.5 * per_level_regen(lvl), 1.5 * per_level_regen(lvl))
	regen = snapped(regen, 0.001)
	var damage = base_damage + randi_range(int(0.5 * per_level_damage(lvl)), int(1.5 * per_level_damage(lvl)))
	var attack_speed = base_attack_speed
	var attack_type = 0
	var attack_level = per_level_attack_level(lvl)
	if randf() > 0.97: attack_level += 1
	var speed = base_speed
	return StatBlock.new(health, regen, damage, attack_speed, attack_type, attack_level, speed)

static func make_exact_from_level(lvl: int):
	var health = base_health + per_level_health(lvl)
	var regen = base_regen + per_level_regen(lvl)
	var damage = base_damage + per_level_damage(lvl)
	var attack_speed = base_attack_speed + per_level_attack_speed(lvl)
	var attack_type = 0
	var attack_level = per_level_attack_level(lvl)
	var speed = 75
	return StatBlock.new(health, regen, damage, attack_speed, attack_type, attack_level, speed)
