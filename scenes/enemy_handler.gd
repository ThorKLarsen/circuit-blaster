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

var elite_enemies = [
	Constants.SPIDER_ELITE
]

var medium_enemy_threat = 10
var large_enemy_threat = 50

# Number of lanes we cna spawn enemies into
var spawn_lanes = 5
@onready var lane_width = (Constants.game_area_size.x - 2*Constants.SIDE_MARGIN_WIDTH)/spawn_lanes

# Time from first to last spawn in a wave.
var wave_time = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func wave_create(stage: int, world: int, wave_n: int) -> Array[SpawnResource]:
	var wave: Array[SpawnResource] = []
	
	if world <= 1:
		var wave_generators = [
			popcorn_cloud_wave,
			popcorn_flow_wave,
			popcorn_lane_wave
		]
		
		wave = wave_generators.pick_random().call(stage, world)
		
		if stage == 4 and wave_n == 3:
			var sr = SpawnResource.new()
			sr.lane = 2
			sr.time_offest = 1
			sr.enemy = load("res://scenes/enemies/fighter_large.tscn")
			wave.append(sr)
		
	else:
		if stage%5 == 4 and wave_n == 2:
			wave = elite_wave(stage, world)
			if world >= 3:
				var wave_generators = [
					popcorn_cloud_wave,
					popcorn_flow_wave,
					popcorn_lane_wave
				]
				
				for sr in wave_generators.pick_random().call(stage, world):
					wave.append(sr)
		else:
			if randf() > 0.5:
				var wave_generators = [
					popcorn_cloud_wave,
					popcorn_flow_wave,
					popcorn_lane_wave
				]
				
				wave = wave_generators.pick_random().call(stage, world)
			else:
				var wave_generators = [
					popcorn_cloud_wave,
					popcorn_flow_wave,
					popcorn_lane_wave
				]
				
				wave = wave_generators.pick_random().call(stage-5, world-1)
				
				for sr in medium_fighter_wave(stage, world):
					wave.append(sr)

	return wave

func wave_create_old(stage: int) -> Array[SpawnResource]:
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

func make_enemy_resource(enemy: PackedScene, lane: int, time_offset: float):
	var enemy_resource = SpawnResource.new()
	enemy_resource.enemy = enemy
	enemy_resource.lane = lane
	enemy_resource.time_offest = time_offset
	return enemy_resource

func get_lane_center(lane: int):
	return Vector2(Constants.left_margin + (lane+0.5)*lane_width, 0)

static func get_threat(stage: int = GameData.stage) -> float:
	var threat = 10 + stage + (stage/5) * 5
	threat *= randfn(1, 0.2)
	return threat


func popcorn_cloud_wave(stage:int, world: int) -> Array[SpawnResource]:
	var wave: Array[SpawnResource] = []
	var threat: float = get_threat(stage)
	var enemies = small_enemies
	var enemy_weights = [10, world]
	
	for i in range(round(threat)):
		var scene = Global.rand_weighted(enemies, enemy_weights)
		var lane = clampi(
			round(randfn((spawn_lanes-1)/2, 1)),
			0, spawn_lanes-1
		)
		var time_offset = clampf(
			randfn(wave_time/2, 1),
			0, wave_time
		)
		wave.append(
			make_enemy_resource(scene, lane, time_offset)
		)
	
	return wave

func popcorn_lane_wave(stage:int, world: int) -> Array[SpawnResource]:
	var wave: Array[SpawnResource] = []
	var threat: float = get_threat(stage)
	var enemies = small_enemies
	var enemy_weights = [10, world]
	
	var lanes = []
	for i in range(3):
		lanes.append(range(spawn_lanes).pick_random())
	
	for i in range(round(threat)):
		var scene = Global.rand_weighted(enemies, enemy_weights)
		var lane = lanes[clamp(round(3*i/(threat)), 0, 2)]
		var time_offset = (i/threat) * wave_time
		wave.append(
			make_enemy_resource(scene, lane, time_offset)
		)
	
	return wave

func popcorn_flow_wave(stage:int, world: int) -> Array[SpawnResource]:
	var wave: Array[SpawnResource] = []
	var threat: float = get_threat(stage)
	var enemies = small_enemies
	var enemy_weights = [10, min(world, 3)]
	
	for i in range(round(threat)):
		var scene = Global.rand_weighted(enemies, enemy_weights)
		var lane = i%(spawn_lanes * 2)
		if lane >= 5:
			lane *= -1
			lane += 8 
		var time_offset = (i/threat) * wave_time
		wave.append(
			make_enemy_resource(scene, lane, time_offset)
		)
	
	return wave

func medium_fighter_wave(stage:int, world: int) -> Array[SpawnResource]:
	var wave: Array[SpawnResource] = []
	var enemies = [Constants.FIGHTER_LARGE, Constants.FIGHTER_LARGE_2]
	var enemy_weights = [1, 1]
	
	var lanes = []
	for i in range(3):
		lanes.append(range(spawn_lanes).pick_random())
	
	var n: int = world - 1
	for i in range(n):
		var scene = Global.rand_weighted(enemies, enemy_weights)
		var lane = range(spawn_lanes-2).pick_random() +1
		var time_offset = (i/n) * wave_time
		wave.append(
			make_enemy_resource(scene, lane, time_offset)
		)
	
	return wave

func elite_wave(stage:int, world: int) -> Array[SpawnResource]:
	var wave: Array[SpawnResource] = []
	var enemies = [Constants.SPIDER_ELITE]
	var enemy_weights = [1]
	
	var lanes = []
	for i in range(3):
		lanes.append(range(spawn_lanes).pick_random())
	
	var scene = Global.rand_weighted(enemies, enemy_weights)
	var lane = 2
	var time_offset = 0
	wave.append(
		make_enemy_resource(scene, lane, time_offset)
	)
	
	return wave
