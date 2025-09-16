extends Node2D

const ZOOM_SPEED = 3.0
const POS_SPEED = 4.0
const ROT_SPEED = 4.0
var target_scale: float = 1.0
var target_pos: Vector2 = Vector2.ZERO
var target_rot: float = 0.0
var cam_scale_before: float = 1.0
#var cam_pos_before: Vector2 = Vector2.ZERO
var resetting_camera: bool = false
var currently_shooting: bool = false # True while shooting any ball
@onready var camera: Camera2D = $Camera2D
@onready var cam_area: Area2D = $Camera2D/Area2D
@onready var table: RigidBody2D = $Table


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	table.sleeping_state_changed.connect(_on_table_sleeping_state_changed)
	table.mouse_entered.connect(_on_table_mouse_entered)
	
	var balls = $Rack.get_balls()
	balls.append($CueBall)
	for ball in balls:
		ball.activate.connect(_on_ball_activate)
		ball.deactivate.connect(_on_ball_deactivate)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currently_shooting:
		return
	if cam_area.overlaps_body(table) and not resetting_camera:
		target_scale += 0.01


func _physics_process(delta: float) -> void:
	if currently_shooting:
		var mouse_pos = get_viewport().get_mouse_position()
		if mouse_pos.x < 30:
			target_scale += 0.0004 * abs(mouse_pos.x - 30)
		if mouse_pos.x > get_viewport_rect().size.x - 30:
			target_scale += 0.0004 * abs(mouse_pos.x - get_viewport_rect().size.x)
		if mouse_pos.y < 30:
			target_scale += 0.0004 * abs(mouse_pos.y - 30)
		if mouse_pos.y > get_viewport_rect().size.y - 30:
			target_scale += 0.0004 * abs(mouse_pos.y - get_viewport_rect().size.y)
		target_scale = clamp(target_scale, 0, 5)
	
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


func within(a: float, b: float, t: float = 0.025) -> bool:
	## Returns true if the difference of a and b is less than a threshold t.
	## Use to compare floats
	return a - b < t


func _on_ball_activate() -> void:
	currently_shooting = true
	cam_scale_before = camera.scale.x
	target_scale = camera.scale.x


func _on_ball_deactivate() -> void:
	currently_shooting = false
	target_scale = cam_scale_before


func _on_table_mouse_entered() -> void:
	if currently_shooting:
		target_scale = cam_scale_before


func _on_table_sleeping_state_changed() -> void:
	if table.sleeping and not currently_shooting:
		target_pos = table.position
		target_rot = table.rotation
		target_scale = 1.0
		resetting_camera = true
		#print('setting cam')
