extends RigidBody2D

const MAX_SINK_VELOCITY: float = 350.0
var overlapping_pocket: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for ball:Ball in overlapping_pocket:
		if ball.linear_velocity.length() <= MAX_SINK_VELOCITY:
			ball.sink(overlapping_pocket[ball])


func start_sink(pocket: Node2D, ball: Ball):
	if ball.linear_velocity.length() <= MAX_SINK_VELOCITY:
		ball.sink(pocket)
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
