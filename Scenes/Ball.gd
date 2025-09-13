extends RigidBody2D

signal shooting_signal(shooting_bool)
signal sink_signal

const ACTIVE_BALL_Z = 13
const ACTIVE_LINE_Z = 12
const ACTIVE_HIGHLIGHT_Z = 11
const INACTIVE_BALL_Z = 3
const INACTIVE_HIGHLIGHT_Z = 1
const VELOCITY_MULTIPLIER = 22

var shooting = false
var sinking = false
var sinking_pocket = null
var multiplier = 1.0
var number = 0


# Called when the node enters the scene tree for the first time.
func _init():
	#connect("shooting", GameManager, "set_shooting")
	shooting_signal.connect(GameManager.set_shooting)
	GameManager.add_ball(self)

func _ready():
	$Line.z_index = ACTIVE_LINE_Z


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shooting:
		if Input.is_action_just_pressed("left_click"):
			#emit_signal("shooting", true)
			shooting_signal.emit(true)
		if Input.is_action_pressed("left_click"):
			position_line()
		else:
			shoot()
		
	elif sinking:
		$Sprite.rotation_degrees += delta * 500
		$Sprite.scale -= Vector2(delta, delta)
#		position.x = move_toward(position.x, sinking_pocket.position.x, delta * 500)
#		position.y = move_toward(position.y, sinking_pocket.position.y, delta * 500)
		global_position = lerp(global_position, sinking_pocket.global_position, delta * 20)
	
	if $Sprite.scale.x <= 0.01:
		queue_free()


#func _physics_process(delta):
#	pass
#	if sinking:
#		rotation_degrees += delta * 500
#		scale -= Vector2(delta, delta)
#		position.x = move_toward(position.x, target_pos.x, delta * 500)
#		position.y = move_toward(position.y, target_pos.y, delta * 500)
#
#	if scale.x <= 0.01:
#		queue_free()


func apply_number(n):
	# give ball number, match sprite
	number = n
	$Sprite.texture = load("res://Assets/Sprites/%d.png" % n)


func shoot():
	var dist = -(get_global_mouse_position() - global_position)
	apply_central_impulse(dist * VELOCITY_MULTIPLIER * multiplier)
	shooting = false
	$Line.visible = false
	$Highlight.visible = false
	GameManager.waiting_for_input = false
	#emit_signal("shooting", false)
	shooting_signal.emit(false)
	reset_z()


func reset_z():
	$Highlight.z_index = INACTIVE_HIGHLIGHT_Z
	$Sprite.z_index = INACTIVE_BALL_Z
	$Line.z_index = ACTIVE_LINE_Z


func position_line():
	var pos = get_local_mouse_position()
	var length = pos.length()
	$Line.set_point_position(1, pos)
	
	if length < 40:
		$Line.self_modulate = Color.BLACK
		multiplier = 0
		
	elif length < 440:
		$Line.self_modulate = Color(
			(length - 40.0) / (439.0 - 40.0),
			1,
			0
		) # Green(0,1,0) -> Yellow(1,1,0)
		multiplier = 0.85
		
	elif length < 840:
		$Line.self_modulate = Color(
			1,
			1 - (length - 440) / ((839-440) * 2),
			0
		) # Yellow(1,1,0) -> Orange(1,.5,0)
		# Green = 1 - (839-440) / (839-440)*2
		multiplier = 1.0
		
	elif length < 1240:
		$Line.self_modulate = Color(
			1,
			0.5 - (length - 840) / ((1239-840) * 2),
			0
		) # Orange(1,.5,0) -> Red(1,0,0)
		multiplier = 1.25
		
	else:
		$Line.self_modulate = Color.RED
		multiplier = 1.5


func sink(pocket_node):
	$CollisionShape2D.set_deferred("disabled", true)
	sleeping = true
	sinking = true
	sinking_pocket = pocket_node
	#emit_signal("sink")
	sink_signal.emit()


func _on_Ball_mouse_entered():
	if GameManager.shooting: return
	$Highlight.visible = true
	$Highlight.z_index = ACTIVE_HIGHLIGHT_Z
	$Sprite.z_index = ACTIVE_BALL_Z


func _on_Ball_mouse_exited():
	if GameManager.shooting: return
	$Highlight.visible = false
	$Highlight.z_index = INACTIVE_HIGHLIGHT_Z
	$Sprite.z_index = INACTIVE_BALL_Z


func _on_Ball_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and !sinking:
		shooting = true
		#emit_signal("shooting", true)
		shooting_signal.emit(true)
		$Line.visible = true
