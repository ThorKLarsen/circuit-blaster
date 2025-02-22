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

var stage = 0
