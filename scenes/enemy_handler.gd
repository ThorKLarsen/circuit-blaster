class_name EnemySpawner extends Node2D

enum EnemyTypes{
	Small,
	Medium,
	Elite
}

var small_enemies = [
	Constants.FIGHTER,
	Constants.FIGHTER_BURST,
]
var small_enemy_threat = 1
var medium_enemies = [
	Constants.FIGHTER_LARGE,
	Constants.VIRUS,
	Constants.SNAKE,
]

var medium_enemy_threat = 10
var large_enemy_threat = 50

# Number of lanes we cna spawn enemies into
var spawn_lanes = 5
@onready var lane_width = (Constants.game_area_size.x - 2*Constants.SIDE_MARGIN_WIDTH)/spawn_lanes

# Time from first to last spawn in a wave.
var wave_time = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func wave_create(stage: int) -> Array[SpawnResource]:
	var r = randf()
	var res: Array[SpawnResource] = []
	
	var threat = get_threat(stage)
	
	# Only popcorn wave
	if r < 0.4:
		# Number of enemies
		var n = round(threat)
		for i in range(n):
			var enemy_resource = make_enemy_resource(
				small_enemies.pick_random(),
				randi_range(0, 4),
				clampf(randfn(wave_time/2., 2), 0, wave_time)
			)
			res.append(enemy_resource)
	# Medium enemy wave
	#elif r < 8:
	else:
		# Number of medium enemies
		var m = round(threat/2)/medium_enemy_threat
		threat -= m * medium_enemy_threat
		for i in range(m):
			var enemy_resource = make_enemy_resource(
				medium_enemies[0],
				[1, 3][i%2], # Alternate between lane 1 and 3
				wave_time/m * i
			)
			res.append(enemy_resource)
		# Number of small enemies
		var n = round(threat)
		for i in range(n):
			var enemy_resource = make_enemy_resource(
				small_enemies[0],
				randi_range(0, 4),
				clampf(randfn(wave_time/2.0, 2), 0, wave_time)
			)
			res.append(enemy_resource)
	# Large enemy wave
	#else:
		#return
		
	return res

func spawm_wave(wave: Array[SpawnResource]):
	for res in wave:
		spawn_enemy(res)

func spawn_enemy(spawn_resource: SpawnResource, randomize_position_in_lane = true):
	var enemy_scene = spawn_resource.enemy.duplicate()
	var enemy = enemy_scene.instantiate()
	enemy.position = get_lane_center(spawn_resource.lane)
	if randomize_position_in_lane:
		enemy.position.x += randf_range(-lane_width/2, lane_width/2)
	get_tree().create_timer(spawn_resource.time_offest).timeout.connect(
		get_parent().add_child.bind(enemy)
	)
	print("Spawning: ", enemy.name, " in ", spawn_resource.time_offest, " ", enemy.position)

func make_enemy_resource(enemy: PackedScene, lane: int, time_offset: float):
	var enemy_resource = SpawnResource.new()
	enemy_resource.enemy = enemy
	enemy_resource.lane = lane
	enemy_resource.time_offest = time_offset
	return enemy_resource

func get_lane_center(lane: int):
	return Vector2(Constants.left_margin + (lane+0.5)*lane_width, 0)

func get_threat(stage: int = GameData.stage):
	var threat = 5 + 3 * stage + round(0.2 * stage**1.3)
	threat *= randfn(1, 0.2)
	return threat


static func popcorn_cloud_wave(threat: float):
	pass

static func popcorn_lane_wave(threat: float):
	pass

static func popcorn_flow_wave(threat: float):
	pass
