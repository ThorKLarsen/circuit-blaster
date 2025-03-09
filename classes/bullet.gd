class_name Bullet extends Object

signal body_entered(bullet, body)

# Game variables
var position_x: float
var position_y: float
var position:
	get(): return Vector2(position_x, position_y)
var damage: float
var velocity: Vector2
var lifetime: float
var transform: Transform2D
var angle: float
var sprite_rect: Rect2

# RID of the bullet's sprite
var canvas_item_RID: RID

var collision_area: RID
var shape: RID
var rotates: bool = true

var killed = false

func _init(
	position: Vector2, # Center of bullet
	damage: float, 
	velocity: Vector2,
	collision_rect: Rect2,
	collision_mask_bitmask: int,
	texture: Texture2D,
	parent_ci: RID,
	physics_space: RID,
	atlas_region: Rect2i = Rect2i(0, 0, 0, 0),
	rotates: bool = true,
	lifetime: float = 20,
):
	# Define variable
	self.position_x = position.x
	self.position_y = position.y
	self.damage = damage
	self.velocity = velocity
	self.lifetime = lifetime
	self.canvas_item_RID = RenderingServer.canvas_item_create()
	if rotates:
		self.angle = velocity.angle()+PI/2
	else:
		self.angle = 0
	
	# Transform, not yet translated by sprite size
	self.transform = Transform2D(
		angle,
		position
	)
	#transform = transform.rotated(angle)
	
	if atlas_region == Rect2i(0, 0, 0, 0):
		sprite_rect = Rect2(-texture.get_size()/2, texture.get_size())
	else:
		sprite_rect = Rect2(-atlas_region.size/2, atlas_region.size)
	
	## Setup collision area
	collision_area = PhysicsServer2D.area_create()
	PhysicsServer2D.area_set_collision_layer(collision_area, 0)
	PhysicsServer2D.area_set_collision_mask(collision_area, collision_mask_bitmask)
	PhysicsServer2D.area_set_monitorable(collision_area, true)
	PhysicsServer2D.area_set_monitor_callback(collision_area, monitor_callback)
	PhysicsServer2D.area_set_space(collision_area, physics_space)
	
	shape = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(
		shape, 
		Vector2(collision_rect.size.x/2, collision_rect.size.y/2),
	)
	
	# Setup canvas item
	RenderingServer.canvas_item_set_parent(canvas_item_RID, parent_ci)
	
	# Using an ordinary texture
	if atlas_region == Rect2i(0, 0, 0, 0):
		RenderingServer.canvas_item_add_texture_rect(
			canvas_item_RID,
			sprite_rect,
			texture,
		)
		PhysicsServer2D.area_add_shape(
			collision_area, 
			shape, 
			Transform2D(angle, texture.get_size()/2)
		)
	else: # Using an atlas texture
		RenderingServer.canvas_item_add_texture_rect_region(
			canvas_item_RID,
			sprite_rect,
			texture,
			atlas_region,
		)
		PhysicsServer2D.area_add_shape(
			collision_area, 
			shape, 
			Transform2D(angle, collision_rect.position)
		)

	RenderingServer.canvas_item_set_transform(
		canvas_item_RID,
		transform
	)
func update(delta):
	position_x += velocity.x * delta
	position_y += velocity.y * delta

	#transform = transform.translated(velocity * delta)
	transform.origin = Vector2(position_x, position_y)
	RenderingServer.canvas_item_set_transform(canvas_item_RID, transform)
	PhysicsServer2D.area_set_transform(collision_area, transform)


	lifetime -= delta
	if lifetime <= 0:
		return false
	else:
		return true

func monitor_callback(
	body_area_status: int,
	body_rid: RID,
	instance_id: int,
	body_shape_idx: int,
	self_shape_idx: int,
):
	if killed:
		return
	var body = instance_from_id(instance_id)
	if body != null:
		body_entered.emit(self, body)

func kill():
	if killed:
		return
	killed = true
	#RenderingServer.free_rid(canvas_item_RID)
	#PhysicsServer2D.free_rid(shape)
	RenderingServer.free_rid.call_deferred(canvas_item_RID)
	PhysicsServer2D.free_rid.call_deferred(shape)
	PhysicsServer2D.free_rid.call_deferred(collision_area) 
	call_deferred("free")
