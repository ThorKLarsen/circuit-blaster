extends Enemy

enum State{
	MOVING,
	SHOOTING
}
var state: State = State.MOVING

var prefered_x: float

@export var shots_per_round = 10
@export var time_per_shot = 1.0/10.
@export var shooting_right: bool = false
var shots_counter = 0
var timer = 0.0

func _ready():
	super._ready()
	prefered_x = position.x
	

func move(delta):
	print(attack_timer.time_left)
	if state == State.SHOOTING:
		timer += delta
		if timer >= time_per_shot:
			timer -= time_per_shot
			shots_counter += 1
			_fire_shot()
			if shots_counter >= shots_per_round:
				shots_counter = 0
				timer = 0
				state = State.MOVING
				
		if shooting_right:
			velocity = Vector2(stat_block.speed, 0)
		else:
			velocity = Vector2(-stat_block.speed, 0)
		
	elif state == State.MOVING:
		velocity.y = stat_block.speed
		velocity.x = lerp(prefered_x - position.x, 0., delta)

func shoot():
	state = State.SHOOTING

func _fire_shot():
	BulletHandler.spawn_bullet(
		get_world_2d(),
		BulletHandler.BulletTypes.ENEMY_BULLET,
		position,
		Vector2(0, 50),
		stat_block.damage,
		BulletHandler.bullet_texture,
		Rect2i(16, 0, 16, 16),
	)
