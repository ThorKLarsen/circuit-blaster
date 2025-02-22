extends Node

enum Stats{
	DAMAGE,
	ATTACK_SPEED,
	MAX_HEALTH,
	REGENERATION,
	SPEED,
}

const TILE_SIZE = 16
const SIDE_MARGIN_WIDTH = 176
var game_area_size: Vector2
var left_margin: float
var right_margin: float
var play_area_rect: Rect2

const NEIGHBORS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]


## === Enemies ===

var FIGHTER = load("res://scenes/enemy.tscn")
var FIGHTER_BURST = load("res://scenes/fighter_burst.tscn")
var VIRUS = load("res://scenes/virus_enemy.tscn")
var SNAKE = load("res://scenes/snake_head.tscn")
var KRAKEN = load("res://scenes/kraken.tscn")
var FIGHTER_LARGE = load("res://scenes/fighter_large.tscn")


func _ready():
	game_area_size = get_viewport().get_visible_rect().size
	left_margin = SIDE_MARGIN_WIDTH
	right_margin = game_area_size.x - SIDE_MARGIN_WIDTH
	play_area_rect = Rect2(left_margin, -100, game_area_size.x - SIDE_MARGIN_WIDTH, game_area_size.y+100)
