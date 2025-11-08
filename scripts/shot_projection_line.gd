extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_trajectory(dir: Vector2, power: float, delta: float) -> void:
	var max_points = 50
	var pos := Vector2.ZERO
	var v = dir * power
	
	clear_points()
	for i in max_points:
		add_point(pos)
		v += dir * power
		
		var collision: KinematicCollision2D = $CollisionTest.move_and_collide(v * delta)
		if collision:
			v = v.bounce(collision.get_normal()) * 0.6
		
		pos += v * delta
		$CollisionTest.position = pos
