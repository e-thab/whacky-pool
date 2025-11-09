class_name Table
extends RigidBody2D

const MAX_SINK_VELOCITY := 350.0
var overlapping_pocket: Dictionary
var last_velocity := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for ball:Ball in overlapping_pocket:
		if ball.linear_velocity.length() <= MAX_SINK_VELOCITY:
			ball.sink(overlapping_pocket[ball].global_position)
	
	# Using a manual sleep implementation because the balls behave more nicely without can_sleep,
	# and the balls being unable to sleep was preventing the table from sleeping as well
	var v = linear_velocity.length()
	if v < PhysicsServer2D.SPACE_PARAM_BODY_LINEAR_VELOCITY_SLEEP_THRESHOLD and v < last_velocity and not sleeping:
		#print('sleep')
		sleeping = true
		sleeping_state_changed.emit()
	elif v >= PhysicsServer2D.SPACE_PARAM_BODY_LINEAR_VELOCITY_SLEEP_THRESHOLD:
		sleeping = false
		sleeping_state_changed.emit()
	last_velocity = v


func start_sink(pocket: Node2D, ball: Ball):
	if ball.linear_velocity.length() <= MAX_SINK_VELOCITY:
		ball.sink(pocket.global_position)
	else:
		overlapping_pocket[ball] = pocket


func _on_pocket_top_left_body_entered(body: Node2D) -> void:
	if body.has_method("sink"):
		start_sink($PocketTopLeft, body)


func _on_pocket_top_middle_body_entered(body: Node2D) -> void:
	if body.has_method("sink"):
		start_sink($PocketTopMiddle, body)


func _on_pocket_top_right_body_entered(body: Node2D) -> void:
	if body.has_method("sink"):
		start_sink($PocketTopRight, body)


func _on_pocket_bottom_left_body_entered(body: Node2D) -> void:
	if body.has_method("sink"):
		start_sink($PocketBottomLeft, body)


func _on_pocket_bottom_middle_body_entered(body: Node2D) -> void:
	if body.has_method("sink"):
		start_sink($PocketBottomMiddle, body)


func _on_pocket_bottom_right_body_entered(body: Node2D) -> void:
	if body.has_method("sink"):
		start_sink($PocketBottomRight, body)


func _on_pocket_top_left_body_exited(body: Node2D) -> void:
	overlapping_pocket.erase(body)


func _on_pocket_top_middle_body_exited(body: Node2D) -> void:
	overlapping_pocket.erase(body)


func _on_pocket_top_right_body_exited(body: Node2D) -> void:
	overlapping_pocket.erase(body)


func _on_pocket_bottom_left_body_exited(body: Node2D) -> void:
	overlapping_pocket.erase(body)


func _on_pocket_bottom_middle_body_exited(body: Node2D) -> void:
	overlapping_pocket.erase(body)


func _on_pocket_bottom_right_body_exited(body: Node2D) -> void:
	overlapping_pocket.erase(body)


func _on_table_area_body_exited(body: Node2D) -> void:
	if body is Ball:
		body.sink(body.global_position)
