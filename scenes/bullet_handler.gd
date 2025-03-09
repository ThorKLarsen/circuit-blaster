extends Node2D

enum BulletTypes{
	PLAYER_BULLET,
	ENEMY_BULLET,
}

var player: CharacterBody2D

var bullets: Array = []
var bullet_texture: Texture = preload("res://assets/CB_spritesheet.png")

var screen_despawn_margin = 32

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	update_bullets(delta)

func update_bullets(delta):
	#var bullets_to_kill = []
	for b in bullets:
		if !b.update(delta): # Returns false if the bullet needs to be deleted
			kill_bullet.call_deferred(b)
		if bullet_is_out_of_bounds(b):
			kill_bullet.call_deferred(b)
			

func spawn_bullet(
	world_2d: World2D,
	type: BulletTypes,
	pos: Vector2,
	velocity: Vector2,
	damage: float,
	texture: Texture2D,
	atlas_region: Rect2i = Rect2i(0, 0, 0, 0),
	collision_rect: Rect2i = Rect2(0, 0, 4, 10),
	rotates: bool = true,
	lifetime: float = 20,
):
	var bullet = Bullet.new(
		pos, 
		damage,
		velocity,
		collision_rect,
		1, 
		texture, 
		get_canvas_item(), 
		world_2d.space, 
		atlas_region,
		rotates,
		lifetime
	)
	if type == BulletTypes.PLAYER_BULLET:
		bullets.append(bullet)
		bullet.body_entered.connect(_on_player_bullet_body_entered)
	elif type == BulletTypes.ENEMY_BULLET:
		bullets.append(bullet)
		bullet.body_entered.connect(_on_enemy_bullet_body_entered)

func kill_bullet(bullet: Bullet):
	bullets.erase(bullet)
	bullet.kill()

func bullet_is_out_of_bounds(bullet: Bullet):
	if bullet.position.x < 0 - screen_despawn_margin:
		return true
	if bullet.position.x > Constants.game_area_size.x + screen_despawn_margin:
		return true
	if bullet.position.y < 0 - screen_despawn_margin:
		return true
	if bullet.position.y > Constants.game_area_size.y + screen_despawn_margin:
		return true
	return false

func is_inside_screen(point: Vector2):
	return get_viewport_rect().has_point(point)

func _on_player_bullet_body_entered(bullet: Bullet, body: Node2D):
	if body.is_in_group("enemy"):
		kill_bullet(bullet)
		if body.has_method("hit"):
			body.hit(bullet.damage)

func _on_enemy_bullet_body_entered(bullet, body):
	if body.is_in_group("player"):
		kill_bullet(bullet)
		if body.has_method("hit"):
			body.hit(bullet.damage)
