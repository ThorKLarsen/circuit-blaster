extends Control

signal shop_opened()
signal shop_closed()

@export var dock: CircuitDock
@export var shop_panels: Array[ShopPanel]

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	for sp in shop_panels:
		sp.item_bought.connect(_on_shop_panel_item_bought)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func open_shop():
	show()
	stock()
	shop_opened.emit()

func stock():
	clear()
	for sp in shop_panels:
		sp.stock()

func clear():
	for sp in shop_panels:
		sp.clear()

func _on_shop_panel_item_bought(circuit: Circuit):
	for sp in shop_panels:
		sp.clear()
	hide()
	shop_closed.emit()
