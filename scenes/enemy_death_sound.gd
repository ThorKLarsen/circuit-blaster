extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.enemy_died.connect(play)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
