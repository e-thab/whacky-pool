extends Node2D

const FADE_GRADIENT: Gradient = preload("res://assets/white_fade_gradient.tres")
#const WHITE_GRADIENT: Gradient = preload("res://assets/white_solid_gradient.tres")

@onready var line_1: Line2D = $FirstLine
@onready var line_2: Line2D = $SecondLine
@onready var test_projectile: CharacterBody2D = $TestProjectile

@onready var projection_ball_1: Sprite2D = $ProjectionBall
@onready var edge_pivot_1: Node2D = $ProjectionBall/EdgePivot
@onready var projection_edge_1: Marker2D = $ProjectionBall/EdgePivot/Edge

#@onready var projection_ball_2: Sprite2D = $ProjectionBall2
#@onready var edge_pivot_2: Node2D = $ProjectionBall2/EdgePivot
#@onready var projection_edge_2: Marker2D = $ProjectionBall2/EdgePivot/Edge

var show_trajectory := false
var working_line: Line2D
#var distance := 0.0


func _process(delta: float) -> void:
	#queue_redraw()
	if show_trajectory:
		line_1.show()
		line_2.show()
		update_trajectory()
	else:
		line_1.hide()
		line_2.hide()
		projection_ball_1.hide()
		#projection_ball_2.hide()


func get_power() -> float:
	return (global_position - get_global_mouse_position()).length()


func get_forward_direction() -> Vector2:
	return -global_position.direction_to(get_global_mouse_position())


func update_trajectory() -> void:
	var velocity: Vector2 = get_power() * get_forward_direction() * 3.68
	var line_start := global_position
	var line_end: Vector2
	var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
	var damping: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
	#var color := Color.WHITE
	var timestep := 0.2
	var second_ball: Ball
	var already_hit_table := false
	var table_bounce_points: Array[Vector2]
	test_projectile.global_position = line_start
	working_line = line_1
	line_1.gradient = FADE_GRADIENT
	line_2.gradient = FADE_GRADIENT
	line_1.clear_points()
	line_2.clear_points()
	line_1.add_point(Vector2.ZERO)
	projection_ball_1.hide()
	#projection_ball_2.hide()
	
	#var bounced := false
	for i in 70:
		#color.a = 1 - i / 70.0
		velocity.y += gravity * timestep
		velocity *= clampf(1.0 - damping * timestep, 0, 1)
		line_end = line_start + (velocity * timestep)
		
		var collision: KinematicCollision2D = test_projectile.move_and_collide(velocity * timestep)
		if collision:
			var body := collision.get_collider()
			if body is Ball:
				#print('ball collide')
				if second_ball:
					#projection_ball_2.global_position = test_projectile.global_position
					#projection_ball_2.show()
					#line_2.gradient = null
					#if table_bounce_points:
						#edge_pivot_2.look_at(table_bounce_points.back())
					#else:
						#edge_pivot_2.look_at(second_ball.global_position)
					#line_2.clear_points()
					#line_2.add_point(second_ball.global_position - global_position)
					#for point in table_bounce_points:
						#line_2.add_point(point - global_position)
					#line_2.add_point(projection_edge_2.global_position - global_position)
					#line_2.add_point(test_projectile.global_position - global_position)
					break
				second_ball = body
				second_ball.set_active_collision_layer()
				projection_ball_1.global_position = test_projectile.global_position
				projection_ball_1.show()
				line_1.gradient = null
				if table_bounce_points:
					edge_pivot_1.look_at(table_bounce_points.back())
				else:
					edge_pivot_1.look_at(get_global_mouse_position())
				line_1.clear_points()
				line_1.add_point(Vector2.ZERO)
				for point in table_bounce_points:
					line_1.add_point(point - global_position)
				line_1.add_point(projection_edge_1.global_position - global_position)
				table_bounce_points.clear()
				velocity = -collision.get_normal() * 75 # * tangent?
				working_line = line_2
				line_start = second_ball.global_position
				test_projectile.global_position = second_ball.global_position
				working_line.add_point(line_start - global_position)
			elif body is Table:
				#print('table collide')
				if already_hit_table or second_ball:
					break
				velocity = velocity.bounce(collision.get_normal()).normalized() * 75
				line_start = test_projectile.global_position
				working_line.add_point(line_start - global_position)
				table_bounce_points.append(line_start)
				already_hit_table = true
		else:
			working_line.add_point(line_end - global_position)
			line_start = line_end
	
	if second_ball:
		second_ball.set_inactive_collision_layer()
