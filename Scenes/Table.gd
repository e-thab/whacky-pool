extends RigidBody2D

signal sink

var MAX_SINK_VELOCITY = GameManager.MAX_SINK_VELOCITY

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.connect("win", self, "win")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func win():
	$WinScreen.visible = true


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
