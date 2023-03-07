extends Node2D


# Declare member variables here. Examples:
var zoom_duration = 0.0
#var target = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Area2D.overlaps_body($Table):
		var start = $Camera2D.zoom.x
		var target = start + 0.1
		var result = lerp(start, target, 0.2)
		zoom_duration += delta
		
		$Camera2D.zoom = Vector2(result, result) 
		position_camera_colliders()
		
	elif zoom_duration > 0:
		zoom_duration = max(zoom_duration - delta, 0)  # need deceleration lerp here
		#print($Camera2D.zoom)


func zoom(n):
	$Camera2D.zoom.x += n
	$Camera2D.zoom.y += n
	position_camera_colliders()


func position_camera_colliders():
	var WIN_WIDTH = 1024
	var WIN_HEIGHT = 600
	
	var h_extent = WIN_WIDTH/2 * $Camera2D.zoom.x  #width top/bottom collision rectangles should be
	var v_extent = WIN_HEIGHT/2 * $Camera2D.zoom.y  #height side collision rectangles should have
	
	$Area2D/CollisionTop.shape.set("extents", Vector2(h_extent, 1))  # setting collider extents
	$Area2D/CollisionTop.position = Vector2(0, -v_extent)  # setting collider position
	
	$Area2D/CollisionBottom.shape.set("extents", Vector2(h_extent, 1))
	$Area2D/CollisionBottom.position = Vector2(0, v_extent)
	
	$Area2D/CollisionLeft.shape.set("extents", Vector2(1, v_extent))
	$Area2D/CollisionLeft.position = Vector2(-h_extent, 0)
	
	$Area2D/CollisionRight.shape.set("extents", Vector2(1, v_extent))
	$Area2D/CollisionRight.position = Vector2(h_extent, 0)


func _on_Area2D_body_exited(body):
	pass
#	print('body exited')
#	zoom(0.25)


func _on_Area2D_body_entered(body):
	print('body entered')
#	zoom(0.125)
