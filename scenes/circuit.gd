class_name Circuit extends TileMapLayer

signal dragging_started
signal dragging_ended

enum CircuitColor{
	GREEN,
	RED,
	YELLOW,
	BLUE
}

class Port:
	# The location of the port relative to the circuit piece
	var location: Vector2i
	# The direction of the adjecent tile which the port is pointing towards.
	var orientation: Vector2i
	#var status: bool = false
	func _init(loc: Vector2i, ori: Vector2i):
		assert(ori.length() == 1)
		location = loc
		orientation = ori

@export var port_layer: TileMapLayer
@export var conn_layer: TileMapLayer
@export var tool_tip: Control
@export var conn_indicator: Label

# Size of the smallest bounding box that can contain the circuit board
var size: Vector2i
# Relative coordinates for each tile withing the bounding box
var shape: Array[Vector2i]
# Location of ports
var ports: Array[Port]
var stat_increases: StatBlock
#var stat_increases: Array = [10, 0, 0, 0, 0,] # Dmg, attspd, hp, regen, speed
var grid: CircuitGrid

var grid_position: Vector2i

var active_connections: int = 0

var draggable: bool = true
var is_dragged: bool = false
var drag_origin: Vector2
var drag_handle_offset: Vector2

var atlas_texture_origin: Vector2i

func _ready():
	tool_tip.hide()

func initialize(
		new_shape: Array[Vector2i], 
		new_ports: Array[Port], 
		new_stat_increases,
		color: CircuitColor,
	):
	circuit_clear()
	shape = new_shape
	ports = new_ports
	stat_increases = new_stat_increases
	match(color):
		CircuitColor.GREEN: atlas_texture_origin = TileNames.CIRCUIT_GREEN
		CircuitColor.RED: atlas_texture_origin = TileNames.CIRCUIT_RED
		CircuitColor.YELLOW: atlas_texture_origin = TileNames.CIRCUIT_YELLOW
		CircuitColor.BLUE: atlas_texture_origin = TileNames.CIRCUIT_BLUE
	
	_initialize_circuit_tiles(new_shape)
	_initialize_port_tiles(new_ports)
	
	#for stat in stat_increases.get_stats().keys():
	tool_tip.get_child(0).text += str(stat_increases)
	
	drag_handle_offset = Vector2(0, 0)
	#for i in range(4):
		#if Vector2i(i, 0) in shape:
			#break
		#else:
			#drag_handle_offset += Vector2(Constants.TILE_SIZE, 0)


func _process(delta):
	if is_dragged:
		global_position = lerp(
			global_position, 
			get_global_mouse_position()
			- Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)/2
			- drag_handle_offset,
			delta*20
		)
		set_tool_tip()


func _input(event):
	
	if event is InputEventMouseMotion:
		var cell = local_to_map(to_local(event.position))
		# Tool tip logic
		if get_cell_atlas_coords(cell) != Vector2i(-1, -1) or is_dragged:
			tool_tip.show()
			set_tool_tip()
		else:
			tool_tip.hide()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if !grid.draggable:
				return
			# Drag and drop
			if event.pressed:
				var cell = local_to_map(to_local(event.position))
				if get_cell_atlas_coords(cell) != Vector2i(-1, -1) and draggable:
					_start_drag(event)
			elif is_dragged:
				_end_drag()

func set_tool_tip():
	var tool_tip_position = global_position + Vector2(-tool_tip.size.x - 32, +24)
	if tool_tip_position.y + tool_tip.size.y > Constants.game_area_size.y:
		tool_tip_position.y = Constants.game_area_size.y - tool_tip.size.y
	#var x_max = get_viewport_rect().size.x - tool_tip.size.x
	#if tool_tip_position.y <= 0:
		#tool_tip_position.y = 0
	#if tool_tip_position.x >= x_max:
		#tool_tip_position.x = x_max
	##if tool_tip_position.y <= 0 and tool_tip_position.x >= x_max:
		##tool_tip_position.x = global_position.x - tool_tip.size.x - 32
	tool_tip.global_position = tool_tip_position
	
	conn_indicator.text = '!'.repeat(active_connections)

func _start_drag(event):
	dragging_started.emit()
	scale = Vector2(1.05, 1.05)
	Global.is_dragging = true
	Global.dragging_object = self
	is_dragged = true
	drag_origin = position
	z_index = 1

func _end_drag():
	dragging_ended.emit()
	scale = Vector2(1, 1)
	Global.is_dragging = false
	Global.dragging_object = null
	is_dragged = false
	z_index =0
	

# Sets the corresponding tiles in the Circuit layer
func _initialize_circuit_tiles(shape):
	for vec in shape:
		set_cell(
			vec,
			0,
			atlas_texture_origin + get_atlas_offset(vec, shape)
		)
		if vec.x+1 > size.x: size.x = vec.x+1
		if vec.y+1 > size.y: size.y = vec.y+1

# Sets the tiles in the Ports layer, and removes invalid ports.
func _initialize_port_tiles(ports):
	var ports_for_deletion = []
	for port in ports:
		# Port locations is on the circuit board
		# And port points to an open space away from the board.
		if port.location in shape \
		and not port.orientation + port.location in shape: 
			port_layer.set_cell(
				port.location,
				0,
				TileNames.PORT_CENTER + port.orientation
			)
		else:
			# If the port is invalid, we delete it on initialization
			ports_for_deletion.append(port)
		
	for port in ports_for_deletion:
		ports.erase(port)

func get_atlas_offset(tile: Vector2i, shape: Array[Vector2i]):
	# Initial offset is 
	var offset = Vector2i(1, 1)
	
	# Neighbor bools
	var left = tile + Vector2i(-1, 0) in shape
	var right = tile + Vector2i(1, 0) in shape
	var up = tile + Vector2i(0, -1) in shape
	var down = tile + Vector2i(0, 1) in shape
	
	if !left and !right:
		offset += Vector2i(2, 0)
	elif !left:
		offset += Vector2i(-1, 0)
	elif !right:
		offset += Vector2i(1, 0)
	
	if !up and !down:
		offset += Vector2i(0, 2)
	elif !up:
		offset += Vector2i(0, -1)
	elif !down:
		offset += Vector2i(0, 1)
	
	return offset
		
func circuit_clear():
	clear()
	port_layer.clear()

func set_connection(location: Vector2i, orientation: Vector2i):
	if orientation == Vector2i(1, 0):
		conn_layer.set_cell(location, 0, TileNames.WIRES_H)
	elif orientation == Vector2i(0, 1):
		conn_layer.set_cell(location, 0, TileNames.WIRES_V)
	
	active_connections += 1


func erase_connection(location: Vector2i):
	conn_layer.erase_cell(location)
