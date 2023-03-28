extends Node2D


# Declare member variables here. Examples:
#var zoom_duration = 0.0
var current_zoom = 5
var target_zoom = 5

var current_rot = 0
var target_rot = 0

var current_pos = Vector2.ZERO
var target_pos = Vector2.ZERO

var ZOOM_SPEED = 2
var ROT_SPEED = 3
var POS_SPEED = 4


func _ready():
	GameManager.add_prog_bar($Table/UI/SlowBar)


func _process(delta):
	if $Camera2D/Area2D.overlaps_body($Table):
		target_zoom += 0.05


func _physics_process(delta):
	if current_zoom != target_zoom:
		current_zoom = lerp(current_zoom, target_zoom, ZOOM_SPEED * delta)
		set_zoom(current_zoom)
	
	if current_rot != target_rot:
		current_rot = lerp(current_rot, target_rot, ROT_SPEED * delta)
		$Camera2D.rotation_degrees = current_rot
	
	if current_pos != target_pos:
		current_pos = lerp(current_pos, target_pos, POS_SPEED * delta)
		$Camera2D.position = current_pos


func set_zoom(n):
	$Camera2D.zoom.x = n
	$Camera2D.zoom.y = n
	position_camera_colliders()


func reset_zoom():
	target_rot = $Table.rotation_degrees
	target_pos = $Table.position
	target_zoom = 5
	position_camera_colliders()


func position_camera_colliders():
	var WIN_WIDTH = 1024
	var WIN_HEIGHT = 600
	
	var h_extent = WIN_WIDTH/2 * $Camera2D.zoom.x  #width top/bottom collision rectangles should be
	var v_extent = WIN_HEIGHT/2 * $Camera2D.zoom.y  #height side collision rectangles should have
	
	$Camera2D/Area2D/CollisionTop.shape.set("extents", Vector2(h_extent, 1))  # setting collider extents
	$Camera2D/Area2D/CollisionTop.position = Vector2(0, -v_extent)  # setting collider position
	
	$Camera2D/Area2D/CollisionBottom.shape.set("extents", Vector2(h_extent, 1))
	$Camera2D/Area2D/CollisionBottom.position = Vector2(0, v_extent)
	
	$Camera2D/Area2D/CollisionLeft.shape.set("extents", Vector2(1, v_extent))
	$Camera2D/Area2D/CollisionLeft.position = Vector2(-h_extent, 0)
	
	$Camera2D/Area2D/CollisionRight.shape.set("extents", Vector2(1, v_extent))
	$Camera2D/Area2D/CollisionRight.position = Vector2(h_extent, 0)


func _on_Table_sleeping_state_changed():
	if $Table.sleeping:
		reset_zoom()


func _on_ClockTimer_timeout():
	GameManager.add_game_seconds(1)
	var seconds = GameManager.game_seconds % 60
	var minutes = GameManager.game_seconds / 60
	$Table/UI/Clock.text = "%02d:%02d" % [minutes, seconds]
