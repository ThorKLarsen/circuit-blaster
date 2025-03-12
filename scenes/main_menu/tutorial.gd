extends Control

@export var highlights: Array[Control]
@export var tutorial_text: Array[String]
@export var text_box: Label

var index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text_box.text = tutorial_text[index]
	for i in range(highlights.size()):
		if i == index:
			highlights[i].show()
		else:
			highlights[i].hide()

func _input(event):
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept"):
		index += 1
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_cancel"):
		index -= 1
	if index < 0 or index >= highlights.size():
		exit()

func exit():
	var scene = preload("res://scenes/main_menu/main_menu.tscn")
	get_tree().change_scene_to_packed(scene)
