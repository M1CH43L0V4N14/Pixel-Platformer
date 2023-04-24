extends Area2D

export(String, FILE, "*.tscn") var targetlLevelPath = ""

var player = false

func go_to_next_room():
	Transitions.playExitLevel()
	get_tree().paused = true
	yield(Transitions, "transitionCompleted")
	get_tree().change_scene(targetlLevelPath)
	get_tree().paused = false
	Transitions.playEnterLevel()

func _process(delta):
	if not player: return
	if not player.is_on_floor(): return
	if Input.is_action_just_pressed("ui_up"):
		if targetlLevelPath.empty(): return
		go_to_next_room()

func _on_Door_body_entered(body):
	if not body is Player: return
	body.on_door = true
	player = body

func _on_Door_body_exited(body):
	if not body is Player: return
	body.on_door = false
	player = null
