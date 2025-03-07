class_name ShopPanel extends Panel

@export var shop: Control
@export var grid: CircuitGrid


var dock: CircuitDock

# Called when the node enters the scene tree for the first time.
func _ready():
	dock = shop.dock


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func stock():
	dock.add_random_circuit(grid)


func buy():
	if grid.circuits.values().size() <= 0:
		return false
	var circuit = grid.circuits.values()[0]
	grid.empty()
	dock.send_circuit_to_input(circuit)
