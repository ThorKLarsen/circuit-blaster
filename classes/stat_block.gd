class_name StatBlock extends Object

enum Stats{
	ATTACK_LEVEL,
	HEALTH,
	REGEN,
	DAMAGE,
	ATTACK_SPEED,
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

var increase_level: Dictionary = {}
var stat_abbreviations: Dictionary = {
	Stats.find_key(Stats.HEALTH): "Health",
	Stats.find_key(Stats.REGEN): "Regen",
	Stats.find_key(Stats.DAMAGE): "Damage",
	Stats.find_key(Stats.ATTACK_SPEED): "AttSpd",
	Stats.find_key(Stats.ATTACK_LEVEL): "AttLvl",
	Stats.find_key(Stats.SPEED): "Speed",
}

func _init(
	new_level,
	new_health,
	new_regen,
	new_damage,
	new_attack_speed,
	new_attack_level,
	new_speed,
	new_increase_level = null
):

	level = new_level
	max_health = new_health
	health = new_health
	regen = new_regen
	damage = new_damage
	attack_speed = new_attack_speed
	attack_level = new_attack_level
	speed = new_speed

	if new_increase_level == null:
		for key in Stats:
			increase_level[key] = 0
	else:
		increase_level = new_increase_level


# Adds two statblocks together.
# Health stat is not symmetic! A.add(B) had the current health of block A
func add(stat_block: StatBlock, mult: float = 1):
	max_health += stat_block.max_health * round(mult)
	health = health
	regen += stat_block.regen * mult
	damage += stat_block.damage * mult
	attack_speed += stat_block.attack_speed * mult
	attack_level += stat_block.attack_level
	speed += stat_block.speed * mult
	return self

func _to_string():
	var res = "LEVEL: " + str(level) + "\n"
	var i = 0
	for key in Stats.keys():

		if get_stats()[key] != 0:
			var n = get_stats()[key]

			res += stat_abbreviations[key]
			res += "\t" + "☼".repeat(increase_level[key]) + "\n"
			res += "\t" + str(snapped(n, 0.05))
			res += "\n"

	return res

func get_stats():
	var stats = {
		Stats.find_key(Stats.HEALTH): health,
		Stats.find_key(Stats.REGEN): regen,
		Stats.find_key(Stats.DAMAGE): damage,
		Stats.find_key(Stats.ATTACK_SPEED): attack_speed,
		Stats.find_key(Stats.ATTACK_LEVEL): attack_level,
		Stats.find_key(Stats.SPEED): speed
		}
	return stats

func get_stat(stat: Stats):
	return get_stats()[stat]

static func make_random_circuit_from_level(lvl: int, size: int):
	
	# Define stats
	var health = 0
	var regen = 0
	var damage = 0
	var attack_speed = 0
	var attack_level = 0
	var speed = 0
	var increase_level: Dictionary = {}
	for key in Stats:
		increase_level[key] = 0
	
	# The number of rolls (each roll can hit a different stat or the same)
	var n = 1
	for i in range(size-1):
		if randf() > 0.6:
			n += 1
	if size >= 5:
		n += 1 + lvl/5
	
	var max_stats = 4
	var used_stats = []
	
	var weights = [2, 10, 10, 10, 6, 5]
	for i in range(n):
		var stat
		if used_stats.size() < max_stats:
			stat = Global.rand_weighted(Stats.values(), weights)
			if !stat in used_stats:
				used_stats.append(stat)
		else:
			stat = used_stats.pick_random()
		
		
		increase_level[Stats.find_key(stat)] += 1
		match(stat):
			Stats.ATTACK_LEVEL: attack_level += 1
			Stats.HEALTH: health += per_level_health(lvl + 2)
			Stats.REGEN: regen += per_level_regen(lvl + 2)
			Stats.DAMAGE: damage += per_level_damage(lvl + 2) * 0.2
			Stats.ATTACK_SPEED: attack_speed += per_level_attack_speed(lvl + 2)
			Stats.SPEED: speed += 20
	
	if lvl <= 0:
		lvl = 0
		if attack_level == 0:
			increase_level[Stats.find_key(Stats.ATTACK_LEVEL)] += 1
			attack_level += 1

	return StatBlock.new(lvl, health, regen, damage, attack_speed, attack_level, speed, increase_level)

static func make_random_enemy_from_level(lvl: int):
	var health = enemy_health(lvl)
	var regen = 1.
	var damage = enemy_damage(lvl)
	var attack_speed = 0.7
	if GameData.world >= 3: attack_speed += (GameData.world-2) * 0.3
	var attack_level = 1 + per_level_attack_level(lvl)
	var speed = base_speed
	return StatBlock.new(lvl, health, regen, damage, attack_speed, attack_level, speed)

static func enemy_health(stage: int):
	return 5. + stage * 5 + 10 * ((stage/5)*((stage/5) + 1))/2

static func enemy_damage(stage: int):
	return 5 + stage + (stage/5) * 5

static func make_base_player():
	var health = 70
	var regen = 0.2
	var damage = 10
	var attack_speed = 1.5
	var attack_level = 1
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
