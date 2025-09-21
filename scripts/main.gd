extends Node2D

const ZOOM_SPEED = 3.0
const POS_SPEED = 4.0
const ROT_SPEED = 4.0
var target_scale := 1.0
var target_pos := Vector2.ZERO
var target_rot := 0.0
var cam_scale_before := 1.0
var wind := Vector2.UP
#var cam_pos_before: Vector2 = Vector2.ZERO
var resetting_camera := false
var currently_shooting := false # True while shooting any ball
var balls: Array[Ball]
var active_ball: Ball
@onready var camera: Camera2D = $Camera2D
@onready var cam_area: Area2D = $Camera2D/Area2D
@onready var table: RigidBody2D = $Table


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	table.sleeping_state_changed.connect(_on_table_sleeping_state_changed)
	table.mouse_entered.connect(_on_table_mouse_entered)
	
	balls = $Rack.get_balls()
	balls.append($CueBall)
	for ball in balls:
		ball.activate.connect(_on_ball_activate)
		ball.deactivate.connect(_on_ball_deactivate)
		ball.ball_freed.connect(_on_ball_freed)
		ball.custom_mouse_entered.connect(_on_ball_mouse_entered)
		#ball.add_constant_force(Vector2.RIGHT * 50)
	#$Rack.queue_free()
	var random_rot = randf_range(0.0, 2.0 * PI)
	wind = Vector2.UP.rotated(random_rot)
	$Camera2D/UI/StaticWindLabel/WindArrow.rotation = random_rot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$Camera2D/UI/CollisionLabel.text = ""
	#for i in range(len(AudioManager.ball_collisions)):
		#if i < len(AudioManager.ball_collisions):
			#$Camera2D/UI/CollisionLabel.text += "[" + AudioManager.ball_collisions[i][0].name + ", " + AudioManager.ball_collisions[i][1].name + "]\n"
		#else:
			#break
	if currently_shooting:
		return
	if cam_area.overlaps_body(table) and not resetting_camera:
		target_scale += 0.01


func _physics_process(delta: float) -> void:
	if currently_shooting:
		var mouse_pos = get_viewport().get_mouse_position()
		var screen_margin = 30
		## Previous cam scale logic: just increase target scale when cursor is within edge margin
		#if mouse_pos.x < screen_margin:
			#target_scale += 0.0004 * abs(mouse_pos.x - screen_margin)
		#if mouse_pos.x > get_viewport_rect().size.x - screen_margin:
			#target_scale += 0.0004 * abs(mouse_pos.x - get_viewport_rect().size.x)
		#if mouse_pos.y < screen_margin:
			#target_scale += 0.0004 * abs(mouse_pos.y - screen_margin)
		#if mouse_pos.y > get_viewport_rect().size.y - screen_margin:
			#target_scale += 0.0004 * abs(mouse_pos.y - get_viewport_rect().size.y)
		#target_scale = clamp(target_scale, 0, 5)
		
		## New logic: linearly scale camera based on cursor distance from center of table.
		## I like the way this feels more, but still needs work. I think it should take x/y components
		## into account rather than just using vector length, because moving to the edge of the screen
		## horizontally causes a jarring snap, but vertically feels good. Calculation also can't stay
		## as originating from center of table since the table's going to move around in the actual game,
		## but this feels like a good start with a static table
		if (camera.scale.x > cam_scale_before
				or mouse_pos.x < screen_margin
				or mouse_pos.x > get_viewport_rect().size.x - screen_margin
				or mouse_pos.y < screen_margin
				or mouse_pos.y > get_viewport_rect().size.y - screen_margin):
			var max_dist := 3000.0
			var min_dist := 300.0
			var mouse_dist = (get_global_mouse_position() - table.global_position).length()
			var calculated_scale: float
			if mouse_dist > min_dist:
				calculated_scale = 4 * ((mouse_dist - 300) / (3000 - 300)) + 1
				calculated_scale = clamp(calculated_scale, 1, 5)
				if calculated_scale < cam_scale_before:
					calculated_scale = cam_scale_before
				else:
					camera.scale = Vector2(calculated_scale, calculated_scale)
			else:
				camera.scale = Vector2(cam_scale_before, cam_scale_before)
			print("dist: %d\tscale: %f\t(before: %f)" % [mouse_dist, calculated_scale, cam_scale_before])
	else:
		camera.scale = lerp(camera.scale, Vector2(target_scale, target_scale), ZOOM_SPEED * delta)
	
	camera.zoom = Vector2(1.0 / camera.scale.x, 1.0 / camera.scale.y)
	
	if camera.position != target_pos and not currently_shooting:
		camera.position = lerp(camera.position, target_pos, POS_SPEED * delta)
	
	if camera.rotation != target_rot and not currently_shooting:
		camera.rotation = lerp(camera.rotation, target_rot, ROT_SPEED * delta)
	
	if resetting_camera:
		if within(camera.scale.x, target_scale) and within(camera.position.x, target_pos.x) and within(camera.rotation, target_rot):
			resetting_camera = false
			#print('cam set')
	
	## Wind (problem: table won't sleep (so cam won't reset) while wind-affected balls are acting on it)
	for ball:Ball in balls:
		ball.apply_central_force(wind * 150)


func within(a: float, b: float, t: float = 0.025) -> bool:
	## Returns true if the difference of a and b is less than a threshold t.
	## Use to compare floats
	return a - b < t


func _on_ball_activate(ball) -> void:
	active_ball = ball
	currently_shooting = true
	cam_scale_before = camera.scale.x
	target_scale = camera.scale.x


func _on_ball_deactivate() -> void:
	active_ball = null
	currently_shooting = false
	target_scale = cam_scale_before


func _on_table_mouse_entered() -> void:
	if currently_shooting:
		target_scale = cam_scale_before


func _on_ball_mouse_entered(ball: Ball) -> void:
	if active_ball == null:
		ball.show_highlight()


func _on_ball_freed(ball: Ball) -> void:
	balls.erase(ball)


func _on_table_sleeping_state_changed() -> void:
	#print('table sleep changed to ', table.sleeping)
	if table.sleeping and not currently_shooting:
		target_pos = table.position
		target_rot = table.rotation
		target_scale = 1.0
		resetting_camera = true
		#print('setting cam')
