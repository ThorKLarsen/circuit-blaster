class_name Game extends Node2D

@export var enemy_spawner: EnemySpawner

var stage_time: float = 60.0
var _stage_timer = 0
var waves_per_stage = 4

var waves = []
var wave_times = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.game = self



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	_stage_timer -= delta
	# When the stage is over, we 
	if _stage_timer <= 0:
		waves.clear()
		wave_times.clear()
		
		_stage_timer = stage_time
		GameData.stage += 1
		for i in range(waves_per_stage):
			var wave = enemy_spawner.wave_create(GameData.stage)
			var time = randfn(
				i * stage_time/(waves_per_stage) + stage_time/(waves_per_stage*2),
				sqrt(stage_time/waves_per_stage)
			)
			time = clampf(time, 5, stage_time)
			
			waves.append(wave)
			wave_times.append(time)
			print("Wave at: ", time)
			get_tree().create_timer(time).timeout.connect(
				enemy_spawner.spawm_wave.bind(wave)
			)
		SignalBus.stage_started.emit(waves, wave_times)
	
