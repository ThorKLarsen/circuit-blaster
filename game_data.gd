extends Node

var player_position: Vector2:
	get():
		return player.position
var player: CharacterBody2D

var game: Game
var stage_timer: 
	get(): return game._stage_timer
var stage_duration:
	get(): return game.stage_time
var wave_times:
	get(): return game.wave_times

var stage: int = -1
var world: int:
	get():
		return 1 + stage/5
	set(value):
		pass


var base_enemy_health:
	get():
		return StatBlock.enemy_health(stage)
var base_enemy_damage:
	get():
		return StatBlock.enemy_damage(stage)
var base_enemy_rank:
	get():
		return world

var attack_mode
func set_attack_mode(value): attack_mode = value

func _ready():
	SignalBus.attack_mode_changed.connect(set_attack_mode)
