extends Node2D

const playerScene = preload("res://Player/Player.tscn")

var playerSpawnLocation = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player
onready var timer: = $Timer

func _ready():
	Transitions.playEnterLevel()
	VisualServer.set_default_clear_color(Color.lightblue)
	player.connectCamera(camera)
	playerSpawnLocation = player.global_position
	Events.connect("playerDied", self, "_on_player_died")
	Events.connect("hitCheckpoint", self, "_on_hit_checkpoint")

func _on_player_died():
	timer.start(1.0)
	yield(timer, "timeout")
	var player = playerScene.instance()
	player.position = playerSpawnLocation
	add_child(player)
	player.connectCamera(camera)

func _on_hit_checkpoint(checkpointPosition):
	playerSpawnLocation = checkpointPosition
