class_name CircuitDock extends Control 

@export var terminal: CircuitGrid
@export var input: CircuitGrid
@export var storage: CircuitGrid
@export var junk: CircuitGrid

var grids: Array[CircuitGrid] = []
var circuits: Array[Circuit] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Find all children grids
	for c in get_children():
		if is_instance_of(c, CircuitGrid):
			grids.append(c)
		if is_instance_of(c, Circuit):
			add_circuit(c)
	
	#add_random_circuit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if Input.is_action_just_pressed("focus"):
		#add_random_circuit()


func add_circuit(circuit: Circuit):
	circuits.append(circuit)
	circuit.dragging_started.connect(_on_circuit_dragging_started.bind(circuit))
	circuit.dragging_ended.connect(_on_circuit_dragging_ended.bind(circuit))


func set_circuit_position(circuit: Circuit, grid: CircuitGrid, coords: Vector2i):
	circuit.position = grid.grid_panels[coords].global_position - global_position

func place_circuit(circuit: Circuit, grid: CircuitGrid, coords: Vector2i):
	# Update grid to contain the circuit
	grid.add_circuit(circuit, coords)
	
	# Move the circuit to the appropriate position
	#circuit.position = grid.grid_panels[coords].global_position - global_position
	set_circuit_position.bind(circuit, grid, coords).call_deferred()

	
	
	if terminal != null:
		var circuits: Array[Circuit]
		for c in terminal.circuits:
			circuits.append(c)
		GameData.player.update_stats(circuits)


func remove_circuit(circuit: Circuit):
	circuits.erase(circuit)

func random_circuit() -> Circuit:
	var color = Circuit.CircuitColor.values().pick_random()
	var shape = get_random_shape()
	var ports = get_random_ports(shape)
	var stats = get_random_stats(shape, ports)
	
	var circuit_scene: PackedScene = load("res://scenes/circuit.tscn")
	var circuit = circuit_scene.instantiate()
	circuit.initialize(shape, ports, stats, color)
	return circuit

func add_random_circuit(grid = input):
	#if grid == null:
		#grid = $Input
	
	var circuit = random_circuit()
	add_child(circuit)
	add_circuit(circuit)
	if grid != null:
		place_circuit(circuit, grid, Vector2i(0, 0))


func get_random_shape():
	var probabilities = [0.03, 0.15, 0.2, 0.3, 0.25, 0.1, 0.05]
	var n = Global.rand_weighted(range(7), probabilities) +1 
	
	# Generate shape
	var res: Array[Vector2i] = [Vector2i(0, 0)] # We start with a tile
	var available_spaces = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for i in range(n-1):
		# Pick a random tile from the space available
		res.append(available_spaces.pick_random())
		
		# Add the spaces around the new tile
		for v in Constants.NEIGHBORS:
			if !((v + res[-1]) in res): # Unless that space is already in the resulting shape
				available_spaces.append(v + res[-1])
				
		# Remove the chosen space from the available list
		available_spaces.erase(res[-1])

	# Move shape
	var offset = Vector2i(0, 0)
	for tile in res:
		offset.x = min(offset.x, tile.x)
		offset.y = min(offset.y, tile.y)
	for i in range(res.size()):
		res[i] -= offset
	
	res = res.filter(func(space): return space.x<4 and space.y<4)
	return res


func get_random_ports(shape: Array[Vector2i]):
	var n: int = shape.size()
	# m is the number of ports to attempt to generate
	var m: int = n / 2
	
	var ports: Array[Circuit.Port] = []
	var orientations = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	for i in range(m):
		# Choose a random port location and orientation.
		var loc = shape.pick_random()
		var ori = orientations.pick_random()
		
		# Check that the port configuration is valid
		for p in ports:
			if p.location == loc:
				loc = null
				break
		if loc == null:
			continue
		
		if loc + ori in shape:
			continue
		
		var port = Circuit.Port.new(
			loc,
			ori,
		)
		ports.append(port)
	return ports


func get_random_stats(shape: Array[Vector2i], ports: Array):
	var n = shape.size()
	
	return StatBlock.make_random_circuit_from_level(GameData.stage, n)


func send_circuit_to_input(circuit: Circuit):
	input.clear()
	place_circuit(circuit, input, Vector2i(0, 0))
	


func _on_circuit_dragging_started(circuit: Circuit):
	pass


func _on_circuit_dragging_ended(circuit: Circuit):

	# Variable to remember if we succeded on placing the circuit
	var circuit_placed = false
	
	for grid in grids:
		if grid.get_rect().has_point(get_global_mouse_position() - global_position):
			var coords = grid.mouse_cell_coords

			if grid.placable and grid.circuit_can_be_placed_at(circuit, coords):
				place_circuit(circuit, grid, coords)
				circuit_placed = true
				break

	if !circuit_placed:
		circuit.position = circuit.drag_origin
