class_name CircuitGrid extends GridContainer


@export var grid_size: Vector2i = Vector2i(4, 4)
@export var placable: bool = true
@export var junk: bool = false
@export var draggable: bool = true
@export var is_terminal: bool = false
@export var cell_node: Control
@export var locked_cells: Array[Vector2i] = []

var grid_panels: Dictionary = {} # Vector2i : Control
var circuits: Array[Circuit] = []

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
	# In a junk grid, we don't care about position.
	if junk:
		return true
		
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
	for stored_circuit in circuits:
		var stored_circuit_coords = stored_circuit.grid_position
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
	circuits.append(circuit)
	circuit.grid_position = coords
	
	update_port_connections()

func update_port_connections():
	
	
	for c:Circuit in circuits:
		c.active_connections = 0

	# Check port connections
	for c1 in circuits:
		var c1_pos:Vector2i = c1.grid_position
		# Loop over each port
		for port:Circuit.Port in c1.ports:
			# We only consider ports facing in positive directions, since every connection will have one of each.
			if port.orientation in [Vector2i(0, 1), Vector2i(1, 0)]:
				c1.erase_connection(port.location)
				# If the grid isn't the terminal, we don't attempt to make connections
				if !is_terminal:
					continue
				#Loop over other circuits
				for c2 in circuits:
					var c2_pos: Vector2i = c2.grid_position
					if c1 == c2:
						continue
					for target_port in c2.ports:
						#Check that target_port is in the correct position and orientation. 
						if target_port.location + c2_pos == port.location + c1_pos + port.orientation\
						and target_port.orientation == -1 * port.orientation:
							c1.set_connection(port.location, port.orientation)
							c2.set_connection(target_port.location, target_port.orientation)
	


# Removes a circuit from grid. Does not free the circuit nor unparent it
func remove_circuit(circuit: Circuit):
	# Remove circuit from dict
	circuits.erase(circuit)
	update_port_connections()
	

func empty():
	for c in circuits:
		remove_circuit(c)


func clear():
	for c in circuits:
		remove_circuit(c)
		c.queue_free.call_deferred()


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
