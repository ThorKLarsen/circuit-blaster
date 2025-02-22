extends Enemy

var state = 0
var hover_height = 50

var start_health
var form = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	start_health = stat_block.health

func hit(value):
	super.hit(value)
	
	if stat_block.health <= start_health/4 and form == 0:
		attack_timer.wait_time *= 0.4
		form += 1

func move(delta):
	if state == 0:
		velocity = Vector2(0, stat_block.speed)
		if position.y >= hover_height:
			state += 1
			position.y = hover_height
			velocity = Vector2(stat_block.speed/2., 0)
	elif state == 1:
		if sign(velocity.x) == 1 \
		and abs(position.x - Constants.right_margin) <= 64:
			velocity.x *= -1
		if sign(velocity.x) == -1 \
		and abs(position.x - Constants.left_margin) <= 64:
			velocity.x *= -1



func shoot():
	var k = 15 # String bullet density (bullets/second)
	var n = 16 # Bullets in one arc
	if stat_block.attack_level > 16:
		n *= 2
	var m = round(attack_timer.wait_time*k)
	
	var strings = []
	var a = clampi((stat_block.attack_level/4)**2, 2, 16)
	for i in range(max(stat_block.attack_level/4, 2)):
		strings.append(
			randi_range(-a, a) * PI/(2*a)
		)
	
	for i in range(n):
		var velocity = Vector2(0, 150).rotated(-PI/2 + i*(PI/n))
		_shoot(velocity)
		
	for angle in strings:
		for i in range(m):
			var velocity = Vector2(0, 150).rotated(angle)

			get_tree().create_timer(i/float(k)).timeout.connect(
				_shoot.bind(velocity)
			)

func _shoot(velocity):
	BulletHandler.spawn_bullet(
		get_world_2d(),
		BulletHandler.BulletTypes.ENEMY_BULLET,
		position,
		velocity,
		10,
		BulletHandler.bullet_texture,
		Rect2i(16*4, 0, 16, 16),
		Rect2i(0, 0, 6, 6),
		false,
	)
