class_name Ball
extends RigidBody2D

signal custom_mouse_entered(ball)
signal activate(ball)
signal ball_freed(ball)
signal deactivate
const HIGHLIGHT_COLOR: Color = Color.AQUA
const ACTIVE_BALL_Z: int = 13
const ACTIVE_LINE_Z: int = 12
const ACTIVE_HIGHLIGHT_Z: int = 11
const INACTIVE_BALL_Z: int = 3
#const INACTIVE_HIGHLIGHT_Z: int = 1
const VELOCITY_MULTIPLIER: float = 12.0

var shooting := false
var sinking := false
var hovering := false
var sinking_pos: Vector2
var ball_num := -1
var shot_strength_multiplier := 1.0
# Stores linear_velocity.length() from the previous physics tick
var last_velocity := 0.0

@export var sprite_texture: Texture2D = preload("res://assets/sprites/cue_ball.png")
@onready var sprite: Sprite2D = $Sprite2D
@onready var highlight: Sprite2D = $Highlight
@onready var line: Line2D = $Line2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = sprite_texture
	sprite.z_index = INACTIVE_BALL_Z
	line.z_index = ACTIVE_LINE_Z
	#projection_line.z_index = ACTIVE_LINE_Z
	highlight.z_index = ACTIVE_HIGHLIGHT_Z
	highlight.self_modulate = HIGHLIGHT_COLOR


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shooting:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			position_line()
		else:
			shoot()


func _physics_process(delta: float) -> void:
	if sinking:
		sprite.rotate(PI/6)
		sprite.scale *= 0.86
		global_position = lerp(global_position, sinking_pos, delta * 20)
	if sprite.scale.x <= 0.01:
		queue_free()
		ball_freed.emit(self)
		
	var v = linear_velocity.length()
	if v < PhysicsServer2D.SPACE_PARAM_BODY_LINEAR_VELOCITY_SLEEP_THRESHOLD and v < last_velocity and not sleeping:
		sleeping = true
		sleeping_state_changed.emit()
	elif v >= PhysicsServer2D.SPACE_PARAM_BODY_LINEAR_VELOCITY_SLEEP_THRESHOLD:
		sleeping = false
		sleeping_state_changed.emit()
	last_velocity = v


#func is_off_table(table_area: Area2D) -> bool:
	#if not $VisibleOnScreenNotifier2D.is_on_screen():
		#return false
	
	#return (
		#global_position.x <= table_position.x - 490
		#or global_position.x >= table_position.x + 490
		#or global_position.y <= table_position.y - 275
		#or global_position.y >= table_position.y + 275
	#)


func set_active() -> void:
	activate.emit(self)
	set_active_collision_layer()


func set_inactive() -> void:
	deactivate.emit()
	set_inactive_collision_layer()


func set_active_collision_layer() -> void:
	## Move ball to 'active' collision layer (2) so that projection does not interact
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)


func set_inactive_collision_layer() -> void:
	## Move ball back to main collision layer (1)
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, false)


func get_shot_power() -> float:
	return get_local_mouse_position().length()


func position_line() -> void:
	var mouse_pos = get_local_mouse_position()
	var length = mouse_pos.length()
	line.set_point_position(1, mouse_pos)
	line.show()
	#projection_line.set_point_position(1, -mouse_pos)
	#projection_line.show()
	
	var color: Color
	if length < 20:
		# 0 strength shot (cancel): Gray
		color = Color.DIM_GRAY
		shot_strength_multiplier = 0
		line.hide()
		#projection_line.hide()
	elif length < 440:
		# Low strength shot: Green(0,1,0) -> Yellow(1,1,0)
		color = Color(
			(length - 20) / (439 - 40),
			1,
			0
		)
		#shot_strength_multiplier = 0.85
		shot_strength_multiplier = 1
	elif length < 840:
		# Low-medium strength: Yellow(1,1,0) -> Orange(1,.5,0)
		color = Color(
			1,
			1 - (length - 440) / ((839-440) * 2),
			0
		)
		shot_strength_multiplier = 1
	elif length < 1240:
		# Medium-high strength: Orange(1,.5,0) -> Red(1,0,0)
		color = Color(
			1,
			0.5 - (length - 840) / ((1239-840) * 2),
			0
		)
		#shot_strength_multiplier = 1.25
		shot_strength_multiplier = 1
	else:
		# High strength: Red
		color = Color.RED
		#shot_strength_multiplier = 1.5
		shot_strength_multiplier = 1
	
	line.self_modulate = color
	highlight.self_modulate = color


func shoot() -> void:
	var dist = -(get_global_mouse_position() - global_position)
	apply_central_impulse(dist * shot_strength_multiplier * VELOCITY_MULTIPLIER)
	#set_axis_velocity(dist * shot_strength_multiplier * 3.0)
	shooting = false
	if not hovering:
		highlight.hide()
		sprite.z_index = INACTIVE_BALL_Z
	set_inactive()
	#projection_line.hide()
	line.hide()
	line.self_modulate = Color.WHITE
	highlight.self_modulate = HIGHLIGHT_COLOR


func sink(pocket_pos: Vector2) -> void:
	play_sound(AudioManager.Sound.POCKET)
	sinking = true
	sinking_pos = pocket_pos
	collision_shape.set_deferred("disabled", true)


func set_ball_number(n: int) -> void:
	sprite.texture = load("res://assets/sprites/%d.png" % n)
	ball_num = n


func show_highlight() -> void:
	highlight.show()
	sprite.z_index = ACTIVE_BALL_Z


func play_sound(sound: int, db_scale: float = 1.0):
	match sound:
		AudioManager.Sound.BALL_HIT:
			var db_variance: float = 8
			#print('ball hit at db scale ', min(db_variance * (2 * db_scale - 1), 25))
			$BallHitSoft.volume_db = min(db_variance * (2 * db_scale - 1), 35)
			$BallHitSoft.pitch_scale = randf_range(0.8, 1.2)
			$BallHitSoft.play()
		AudioManager.Sound.TABLE_HIT:
			var db_variance: float = 4
			#print('table hit at db scale ', min(db_variance * (2 * db_scale - 1), 25))
			$TableHit.volume_db = min(db_variance * (2 * db_scale - 1), 25)
			$TableHit.pitch_scale = randf_range(0.1, 0.6)
			$TableHit.play()
		AudioManager.Sound.POCKET:
			var db_variance: float = 4
			#print('pocket at db scale ', db_variance * (2 * db_scale - 1))
			$Pocket.volume_db = db_variance * (2 * db_scale - 1)
			$Pocket.pitch_scale = randf_range(0.8, 1.2)
			$Pocket.play()


func _to_string() -> String:
	return "{Ball %d}" % [ball_num]


func _on_mouse_entered() -> void:
	## Uses a signal so that main can decide to only highlight when there is no active ball
	hovering = true
	custom_mouse_entered.emit(self)
 

func _on_mouse_exited() -> void:
	hovering = false
	if not shooting:
		highlight.hide()
		highlight.self_modulate = HIGHLIGHT_COLOR
		sprite.z_index = INACTIVE_BALL_Z


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			line.show()
			shooting = true
			set_active()


func _on_body_entered(body: Node) -> void:
	if body is Ball or body is Table:
		AudioManager.report_collision(self, body)


func _on_screen_exited() -> void:
	#print(self, ': exit')
	pass
