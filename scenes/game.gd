class_name Game extends Node2D

enum GameState{
	Menu,
	Stage,
	Shop
}

@export var enemy_spawner: EnemySpawner

var game_state = GameState.Stage
var stage_time: float = 45.0
var _stage_timer = 0
var waves_per_stage = 4

var shop_interval = 4

var waves = []
var wave_times = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.game = self
	open_shop()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if _stage_timer > 0:
		_stage_timer -= delta
	# When the stage is over, we 
	if _stage_timer <= 0:
		if get_tree().get_nodes_in_group("enemy").size() != 0:
			_stage_timer += 1
		elif game_state != GameState.Shop:
			open_shop()



func next_stage():
	game_state = GameState.Stage
	waves.clear()
	wave_times.clear()
	
	_stage_timer = stage_time
	GameData.stage += 1
	for i in range(waves_per_stage):
		var wave = enemy_spawner.wave_create(GameData.stage, GameData.world, i)
		var time = randfn(
			i * stage_time/(waves_per_stage) + stage_time/(waves_per_stage*2),
			sqrt(stage_time/waves_per_stage)
		)
		time = clampf(time, 5, stage_time - 5)
		
		waves.append(wave)
		wave_times.append(time)
		get_tree().create_timer(time).timeout.connect(
			enemy_spawner.spawm_wave.bind(wave)
		)
	SignalBus.stage_started.emit(waves, wave_times)


func open_shop():
	game_state = GameState.Shop
	$CanvasLayer/Shop.open_shop()


func _on_shop_shop_closed():
	next_stage()
