extends Node2D

enum {HOVER, FALL, LAND, RISE}

export(int) var riseSpeed = 50
export(int) var fallSpeed = 160

var state = HOVER

onready var startPosition = global_position
onready var timer: = $Timer
onready var raycast: = $RayCast2D
onready var animatedSprite: = $AnimatedSprite
onready var particles: = $Particles2D

func _ready():
	particles.one_shot = true

func _physics_process(delta):
	match state:
		HOVER: hoverState()
		FALL: fallState(delta)
		LAND: landState()
		RISE: riseState(delta)

func hoverState():
	state = FALL

func fallState(delta):
	animatedSprite.play("Falling")
	position.y += fallSpeed * delta
	if raycast.is_colliding():
		var collisionPoint = raycast.get_collision_point()
		position.y = collisionPoint.y
		state = LAND
		timer.start(1)
		particles.emitting = true

func landState():
	if timer.time_left == 0: state = RISE

func riseState(delta):
	animatedSprite.play("Rising")
	position.y = move_toward(position.y, startPosition.y, riseSpeed * delta)
	if position.y == startPosition.y:
		state = HOVER
