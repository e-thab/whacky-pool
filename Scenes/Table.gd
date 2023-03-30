extends RigidBody2D

signal sink
#signal table_sleeping_state_changed(state)

var MAX_SINK_VELOCITY = GameManager.MAX_SINK_VELOCITY

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("sink", GameManager, "sink")
	#connect("table_sleeping_state_changed", GameManager, "on_table_sleeping_state_changed")
	GameManager.connect("win", self, "win")
	GameManager.connect("update_score", self, "on_update_score")
	GameManager.connect("update_combo", self, "on_update_combo")
	GameManager.add_prog_bar($UI/SlowBar)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !sleeping:
#		$UI/MoveBar.value = linear_velocity.length() + angular_velocity
		var target_val = linear_velocity.length() + angular_velocity
		$UI/MoveBar.value = lerp($UI/MoveBar.value, target_val, delta*10)
	else:
		$UI/MoveBar.value = 0


func win():
	$WinScreen/WinScore.text = "SCORE: %d" % GameManager.score
	$WinScreen.visible = true


func update_clock():
	var seconds = GameManager.game_seconds % 60
	var minutes = GameManager.game_seconds / 60
	
	if minutes > 99:
		$UI/Clock.text = "BREAK:TIME"
	else:
		$UI/Clock.text = "%02d:%02d" % [minutes, seconds]


func on_update_score():
	$UI/Score.text = "SCORE: %d" % GameManager.score


func on_update_combo():
	$UI/Combo.text = "COMBO: %d" % GameManager.combo


func _on_PocketTopLeft_body_entered(body):
	if body.linear_velocity.length() < MAX_SINK_VELOCITY:
		body.sink($PocketTopLeft/PocketPosition)
		emit_signal("sink")


func _on_PocketTopMiddle_body_entered(body):
	if body.linear_velocity.length() < MAX_SINK_VELOCITY:
		body.sink($PocketTopMiddle/PocketPosition)
		emit_signal("sink")


func _on_PocketTopRight_body_entered(body):
	if body.linear_velocity.length() < MAX_SINK_VELOCITY:
		body.sink($PocketTopRight/PocketPosition)
		emit_signal("sink")


func _on_PocketBottomLeft_body_entered(body):
	if body.linear_velocity.length() < MAX_SINK_VELOCITY:
		body.sink($PocketBottomLeft/PocketPosition)
		emit_signal("sink")


func _on_PocketBottomMiddle_body_entered(body):
	if body.linear_velocity.length() < MAX_SINK_VELOCITY:
		body.sink($PocketBottomMiddle/PocketPosition)
		emit_signal("sink")


func _on_PocketBottomRight_body_entered(body):
	if body.linear_velocity.length() < MAX_SINK_VELOCITY:
		body.sink($PocketBottomRight/PocketPosition)
		emit_signal("sink")


func _on_Button_pressed():
	GameManager.reset()
