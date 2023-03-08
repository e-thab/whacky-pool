extends RigidBody2D


# Declare member variables here. Examples:
var shooting = false
var multiplier = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shooting:
		if Input.is_action_pressed("left_click"):
			position_line()
		else:
			shoot()


func shoot():
	var dist = -(get_global_mouse_position() - global_position)
	apply_central_impulse(dist * 12 * multiplier)
	shooting = false
	$Line.visible = false


func position_line():
	var pos = get_local_mouse_position()
	$Line.set_point_position(1, pos)
	
	if pos.length() < 40:
		$Line.self_modulate = Color.black
		multiplier = 0
		
	elif pos.length() < 300:
		$Line.self_modulate = Color.green
		multiplier = 0.85
		
	elif pos.length() < 600:
		$Line.self_modulate = Color.yellow
		multiplier = 1.0
		
	elif pos.length() < 900:
		$Line.self_modulate = Color.orange
		multiplier = 1.15
		
	else:
		$Line.self_modulate = Color.red
		multiplier = 1.5


func _on_Ball_mouse_entered():
	$Highlight.visible = true
	$Highlight.z_index = 10
	$Sprite.z_index = 11


func _on_Ball_mouse_exited():
	$Highlight.visible = false
	$Highlight.z_index = 0
	$Sprite.z_index = 1


func _on_Ball_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		shooting = true
		$Line.visible = true
