class_name Area2d extends Component

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()



func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.kill(false)
