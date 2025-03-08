class_name ShopPanel extends Panel

signal item_bought(circuit)

@export var shop: Control
@export var grid: CircuitGrid
@export var desc_label: RichTextLabel


var dock: CircuitDock

# Called when the node enters the scene tree for the first time.
func _ready():
	dock = shop.dock


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func stock():
	dock.add_random_circuit(grid)
	var circuit = grid.circuits.values()[0]
	desc_label.text = circuit.tool_tip.get_child(0).text

func clear():
	grid.clear()

func buy():
	if grid.circuits.values().size() <= 0:
		return false
	var circuit = grid.circuits.values()[0]
	grid.empty()
	dock.send_circuit_to_input(circuit)
	item_bought.emit(circuit)
