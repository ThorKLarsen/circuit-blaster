extends Control

@export var straight_indicator: TextureRect
@export var burst_indicator: TextureRect
@export var wide_indicator: TextureRect

var straight_coords = Vector2(256, 96)
var burst_coords = Vector2(288, 96)
var wide_coords = Vector2(224, 96)

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.attack_mode_changed.connect(_on_player_attack_mode_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset_attack_mode():
	straight_indicator.texture.region.position.y = 128
	burst_indicator.texture.region.position.y = 128
	wide_indicator.texture.region.position.y = 128

func _on_player_attack_mode_changed(mode):
	reset_attack_mode()
	if mode == 0:
		straight_indicator.texture.region.position.y = 96
	if mode == 1:
		wide_indicator.texture.region.position.y = 96
	if mode == 2:
		burst_indicator.texture.region.position.y = 96
		
