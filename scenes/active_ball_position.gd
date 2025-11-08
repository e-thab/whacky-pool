extends Marker2D


@onready var test_projectile: CharacterBody2D = $"TestProjectile"
var show_trajectory := false
#var distance := 0.0


func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if show_trajectory:
		update_trajectory()


func get_power() -> float:
	return 2.5 * (global_position - get_global_mouse_position()).length()


func get_forward_direction() -> Vector2:
	return -global_position.direction_to(get_global_mouse_position())


func draw_line_global(point_a: Vector2, point_b: Vector2, color: Color, width: int = 3) -> void:
	var local_offset := point_a - global_position
	var point_b_local := point_b - global_position
	#var max_distance := get_power() / 2.5
	#distance += (point_b_local - local_offset).length()
	#if distance > max_distance:
		#color.a = 1.0 - distance / max_distance
	draw_line(local_offset, point_b_local, color, width)


func update_trajectory() -> void:
	var velocity: Vector2 = get_power() * get_forward_direction()
	var line_start := global_position
	var line_end: Vector2
	var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
	var damping: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
	var color := Color.NAVY_BLUE
	var timestep := 0.2
	#distance = 0.0
	test_projectile.global_position = line_start
	
	for i in 30:
		color.g = 1 - i / 30.0
		velocity.y += gravity * timestep
		velocity = velocity * clampf(1.0 - damping * timestep, 0, 1)
		line_end = line_start + (velocity * timestep)
		
		var collision := test_projectile.move_and_collide(velocity * timestep)
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			#draw_line_global(line_start, test_projectile.global_position, Color.YELLOW)
			draw_line_global(line_start, test_projectile.global_position, color)
			line_start = test_projectile.global_position
			#distance *= 1.2
			continue
		
		draw_line_global(line_start, line_end, color)
		line_start = line_end
