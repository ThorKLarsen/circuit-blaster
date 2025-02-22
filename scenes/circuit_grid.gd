class_name CircuitGrid extends GridContainer


@export var grid_size: Vector2i = Vector2i(4, 4)
@export var placable: bool = true
@export var junk: bool = false
@export var cell_node: Control
@export var locked_cells: Array[Vector2i] = []

var grid_panels: Dictionary = {} # Vector2i : Control
var circuits: Dictionary = {} # Vector2i : Circuit

var mouse_cell_coords: Vector2i = Vector2i(-1, -1) # Vector2i( -1, -1) means mouse is ouside grid

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup 'grid_panels' and fill it with duplicates of 'cell_node'
	size = Vector2(grid_size) * Constants.TILE_SIZE
	columns = grid_size.x
	
	# The order of the for statements is important here! Since GridContainers fill by column first
	for j in range(grid_size.y):
		for i in range(grid_size.x):
			var cell
			if i == 0 and j == 0:
				cell = cell_node
			else:
				cell = cell_node.duplicate()
				add_child(cell)
				
			cell.modulate.a = 0
			cell.custom_minimum_size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
			grid_panels[Vector2i(i, j)] = cell
			cell.mouse_entered.connect(_on_cell_mouse_entered.bind(Vector2i(i, j)))
			cell.mouse_exited.connect(_on_cell_mouse_exited.bind(Vector2i(i, j)))


func highlight_circuit_placement(circuit: Circuit, coords: Vector2i):
	#Green highlight
	if circuit_can_be_placed_at(circuit, coords):
		for vec in circuit.shape:
			if (vec + coords) in grid_panels.keys():
				var clr = Color.AQUAMARINE
				clr.a = 0.7
				grid_panels[vec + coords].modulate = clr
	else:
		for vec in circuit.shape:
			if (vec + coords) in grid_panels.keys():
				var clr = Color.CRIMSON
				clr.a = 0.7
				grid_panels[vec + coords].modulate = clr


func highlight_clear():
	for k in grid_panels.keys():
		grid_panels[k].modulate = Color.WHITE
		grid_panels[k].modulate.a = 0


func circuit_can_be_placed_at(circuit: Circuit, coords: Vector2i):
	# Check if Circuit can fit inside grid
	if coords.x < 0 or coords.y < 0 \
	or coords.x + circuit.size.x > grid_size.x \
	or coords.y + circuit.size.y > grid_size.y:
		return false
	
	# Check if overlapping a locked cell
	for tile in circuit.shape:
		if tile + coords in locked_cells:
			return false
	
	# Check is circuit overlaps already existing circuits
	for stored_circuit_coords in circuits.keys():
		var stored_circuit = circuits[stored_circuit_coords]
		if stored_circuit == circuit:
			continue
		for vec in stored_circuit.shape:
			if vec + stored_circuit_coords - coords in circuit.shape:
				return false

	return true

func add_circuit(circuit: Circuit, coords: Vector2i):
	# Remove circuit from previous grid
	if circuit.grid != null:
		circuit.grid.remove_circuit(circuit)
	circuit.grid = self
	
	# If this is a junk grid, just free and return
	if junk:
		circuit.queue_free()
		return true

	# Add circuit to dictionary
	circuits[coords] = circuit


func remove_circuit(circuit: Circuit):
	# Remove circuit from dict
	circuits.erase(circuits.find_key(circuit))


func _on_cell_mouse_entered(coords: Vector2i):
	mouse_cell_coords = coords
	if !Global.is_dragging:
		grid_panels[coords].modulate.a = 0.7
	if Global.is_dragging \
	and Global.dragging_object is Circuit:
		highlight_circuit_placement(Global.dragging_object, coords)

func _on_cell_mouse_exited(coords: Vector2i):
	if mouse_cell_coords == coords:
		mouse_cell_coords = Vector2i( -1, -1)

	grid_panels[coords].modulate.a = 0
	highlight_clear()
