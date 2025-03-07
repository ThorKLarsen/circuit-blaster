class_name ShopPanel extends Panel

@export var dock: CircuitDock
@export var grid: CircuitGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func stock():
	dock.add_random_circuit(grid)


func buy():
	var circuit = grid.circuits.values()[0]
	grid.empty()
	dock.send_circuit_to_input(circuit)
