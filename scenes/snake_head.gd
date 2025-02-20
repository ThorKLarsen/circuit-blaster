extends Enemy

@export var number_of_links: int = 10
@export var body_sprite: Sprite2D

var is_head = true
var parent = null
var child = null

var link_offset = 10
var from_point: Vector2
var target_point: Vector2:
	set(value):
		target_point = value
		from_point = global_position
		if child != null:
			child.target_point = global_position

var angle = 0
var angl_velocity = (PI)/2 # Radians Pr. Second
var radius = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if is_head:
		velocity = Vector2(0, speed/8)
	set_sprite()
	angle = -PI
	
	if number_of_links > 0:
		spawn_link()

func move(delta):
	if is_head:
		velocity = (radius * angl_velocity) * Vector2(cos(angle), sin(angle))
		
		if (position.x - Constants.left_margin) <= 50:
			velocity += Vector2(20, 0)
		if (Constants.right_margin - position.x) <= 50:
			velocity += Vector2(-20, 0)
		
		angle += angl_velocity * delta
		if angle >= PI:
			angle -= PI
			angl_velocity *= -1
		elif angle <= -PI:
			angle += PI
			angl_velocity *= -1
		if child != null:
			if abs(global_position - child.target_point).length() >= link_offset/2.:
				child.target_point = global_position
	else:
		var a = Geometry2D.segment_intersects_circle(from_point, target_point, parent.global_position, link_offset)
		global_position = lerp(from_point, target_point, a)
		if (global_position - parent.global_position).length() > link_offset:
			global_position =  parent.global_position + parent.global_position.direction_to(global_position) * link_offset


func set_sprite():
	if is_head:
		sprite.show()
		body_sprite.hide()
	else:
		sprite.hide()
		body_sprite.show()

func shoot():
	pass
	

func spawn_link():
	var link_scene = preload("res://scenes/snake_head.tscn")
	var link = link_scene.instantiate()
	link.is_head = false
	link.number_of_links = number_of_links-1
	link.position = global_position + Vector2(0, -link_offset)
	link.parent = self
	link.target_point = global_position
	child = link
	get_parent().add_child.call_deferred(link)

func kill(player_kill: bool = true):
	if parent != null:
		parent.child = null
	if child != null:
		child.parent = null
		child.is_head = true
		child.set_sprite()
		if !player_kill:
			child.angle = 0
	super.kill()
