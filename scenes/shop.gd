extends Control

@export var shop_panels: Array[ShopPanel]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event.is_action_pressed("focus"):
		stock()

func stock():
	for sp in shop_panels:
		sp.stock()
