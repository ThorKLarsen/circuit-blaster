extends TextureProgressBar

@export var line_marker: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	line_marker.hide()
	SignalBus.stage_started.connect(update_wave_marker_lines)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = 100 * GameData.stage_timer/GameData.stage_duration


func update_wave_marker_lines(waves, wave_times):
	for c in get_children():
		if c != line_marker:
			c.queue_free()
	
	for wave_time in wave_times:
		var marker = line_marker.duplicate()
		marker.show()
		marker.position.y = Constants.game_area_size.y * wave_time/GameData.stage_duration
		add_child(marker)
