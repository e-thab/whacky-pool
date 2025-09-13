extends Node2D

const ZOOM_SPEED: float = 2.0
const POS_SPEED: float = 4.0
const ROT_SPEED: float = 3.0
var target_zoom: float = 1.0
var target_pos: Vector2 = Vector2.ZERO
var target_rot: float = 0.0
@onready var camera: Camera2D = $Camera2D
@onready var cam_area: Area2D = $Camera2D/Area2D
@onready var table: RigidBody2D = $Table


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	table.sleeping_state_changed.connect(_on_table_sleeping_state_changed)
	$Timer.timeout.connect(timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cam_area.overlaps_body(table):
		target_zoom += 0.01
		#print('overlapping')


func _physics_process(delta: float) -> void:
	camera.scale = lerp(camera.scale, Vector2(target_zoom, target_zoom), ZOOM_SPEED * delta)
	camera.zoom.x = 1.0 / camera.scale.x
	camera.zoom.y = 1.0 / camera.scale.y
	
	if camera.position != target_pos:
		camera.position = lerp(camera.position, target_pos, POS_SPEED * delta)
	
	if camera.rotation != target_rot:
		camera.rotation = lerp(camera.rotation, target_rot, ROT_SPEED * delta)
	#print('camera zoom = ', camera.zoom.x, ', 1/tz = ', 1.0 / target_zoom)
	#print(camera.zoom.x - 1.0 / target_zoom)
	
	#if camera.position != table.position:
		#camera.position = lerp(camera.position, table.position, POS_SPEED * delta)


func timer_timeout() -> void:
	if get_node_or_null("Ball"):
		print('free ball')
		$Ball.queue_free()


func _on_table_sleeping_state_changed() -> void:
	if table.sleeping:
		target_pos = table.position
		target_rot = table.rotation
