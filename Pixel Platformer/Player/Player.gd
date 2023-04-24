extends KinematicBody2D
class_name Player

enum { MOVE, CLIMB }

export(Resource) var moveData = preload("res://Player/DefaultPlayerMovementData.tres") as PlayerMovementData

var velocity = Vector2.ZERO
var state = MOVE
var doubleJump = 1
var bufferedJump = false
var coyoteJump = false
var on_door = false

onready var animatedSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D



func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: moveState(input, delta)
		CLIMB: climbState(input)

func moveState(input, delta):
	if isOnLadder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB
	applyGravity(delta)
	
	if not horizontalMove(input):
		applyFriction(delta)
		animatedSprite.animation = "Idle"
	else:
		applyAcceleration(input.x, delta)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0
	
	
	if is_on_floor(): resetDoubleJump()
	else: animatedSprite.animation = "Jump"
	
	if canJump(): inputJump()
	else:
		inputJumpRelease()
		inputDoubleJump()
		bufferJump()
		fastFall(delta)
	
	var wasInAir = not is_on_floor()
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	var justLanded = is_on_floor() and wasInAir
	if justLanded:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
	var justLeftGround = not is_on_floor() and wasOnFloor
	if justLeftGround and velocity.y >= 0:
		coyoteJump = true
		coyoteJumpTimer.start()

func climbState(input):
	if not isOnLadder(): state = MOVE
	if input.length() != 0: animatedSprite.animation = "Run"
	else: animatedSprite.animation = "Idle"
	velocity = input * moveData.climbSpeed
	velocity = move_and_slide(velocity, Vector2.UP)

func playerDie():
	SoundPlayer.playSound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("playerDied")

func connectCamera(camera):
	var cameraPath = camera.get_path()
	remoteTransform2D.remote_path = cameraPath

func inputJumpRelease():
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.jumpReleaseForce:
		velocity.y = moveData.jumpReleaseForce

func inputDoubleJump():
	if Input.is_action_just_pressed("ui_up") and doubleJump > 0:
		SoundPlayer.playSound(SoundPlayer.JUMP)		
		velocity.y = moveData.jumpForce
		doubleJump -= 1

func bufferJump():
	if Input.is_action_pressed("ui_up"):
		bufferedJump = true
		jumpBufferTimer.start()

func fastFall(delta):
	if velocity.y > 0:
		velocity.y += moveData.additionalFallGravity * delta

func inputJump():
	if on_door: return
	if Input.is_action_just_pressed("ui_up") or bufferedJump:
		SoundPlayer.playSound(SoundPlayer.JUMP)
		velocity.y = moveData.jumpForce
		bufferedJump = false

func canJump():
	return is_on_floor() or coyoteJump

func horizontalMove(input):
	return input.x != 0

func resetDoubleJump():
	doubleJump = moveData.doubleJumpCount

func isOnLadder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func applyGravity(delta):
	velocity.y += moveData.gravity * delta
	velocity.y = min(velocity.y, 300)

func applyFriction(delta):
	velocity.x = move_toward(velocity.x, 0, moveData.friction * delta)

func applyAcceleration(amount, delta):
	velocity.x = move_toward(velocity.x, moveData.maxSpeed * amount, moveData.acceleration * delta)


func _on_JumpBufferTimer_timeout():
	bufferedJump = false

func _on_CoyoteJumpTimer_timeout():
	coyoteJump = false
