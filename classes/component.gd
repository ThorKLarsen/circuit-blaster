class_name Component extends Node

var agent: Node2D

func _ready():
	_late_ready.call_deferred()
	
func _late_ready():
	agent = get_parent()
