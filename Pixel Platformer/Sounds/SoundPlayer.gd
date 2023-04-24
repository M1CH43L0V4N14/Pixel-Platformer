extends Node

const HURT = preload("res://Sounds/Hurt.wav")
const JUMP = preload("res://Sounds/Jump.wav")

onready var audioPLayers: = $AudioPlayers

func playSound(sound):
	for audioStreamPlayer in audioPLayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
