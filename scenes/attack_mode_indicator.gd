extends TextureRect

var straight_coords = Vector2(224, 112)
var burst_coords = Vector2(256, 112)
var wide_coords = Vector2(224, 80)

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.attack_mode_changed.connect(_on_player_attack_mode_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_attack_mode_changed(mode):
	if mode == 0:
		texture.region.position = straight_coords
	if mode == 1:
		texture.region.position = wide_coords
	if mode == 2:
		texture.region.position = burst_coords
