extends CanvasLayer

onready var animationPlayer = $AnimationPlayer

signal transitionCompleted

func playExitLevel():
	animationPlayer.play("ExitLevel")
	

func playEnterLevel():
	animationPlayer.play("EnterLevel")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("transitionCompleted")
