tool
extends Path2D


enum animationType {
	loop,
	bounce
}

export(animationType) var animation_type setget setAnimationType
export(int) var speed setget set_speed

onready var animationPlayer: = $AnimationPlayer

func setAnimationType(value):
	animation_type = value
	var ap = find_node("AnimationPlayer")
	if ap: playUpdatedAnimation(ap)

func set_speed(value):
	speed = value
	var ap = find_node("AnimationPlayer")
	if ap: ap.playback_speed = speed

func _ready():
	playUpdatedAnimation(animationPlayer)

func playUpdatedAnimation(ap):
	match animation_type:
		animationType.loop: ap.play("MoveAlongPathLoop")
		animationType.bounce: ap.play("MoveAlongPathBounce")
