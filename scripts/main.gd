extends Node2D

const ZOOM_SPEED := 3.0
const POS_SPEED := 4.0
const ROT_SPEED := 4.0
const GEAR_ICON = preload("res://assets/sprites/gear.png")
const MINUS_ICON = preload("res://assets/sprites/minus.png")
const BUS_LAYOUT = preload("res://assets/bus_layout.tres")
@export var wind := false # use wind?
@export var show_shot_power := true
var target_scale := 1.0
var target_pos := Vector2.ZERO
var target_rot := 0.0
var cam_scale_before := 1.0
var wind_dir := Vector2.UP
#var cam_pos_before: Vector2 = Vector2.ZERO
var resetting_camera := false
var currently_shooting := false # True while shooting any ball
var balls: Array[Ball]
var active_ball: Ball
@onready var camera: Camera2D = $Camera2D
@onready var cam_area: Area2D = $Camera2D/Area2D
@onready var table: RigidBody2D = $Table
@onready var settings_menu: PanelContainer = $Camera2D/UI/SettingsMenu
@onready var power_label: Label = $Camera2D/UI/PowerLabel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_layout(BUS_LAYOUT)
	table.sleeping_state_changed.connect(_on_table_sleeping_state_changed)
	table.mouse_entered.connect(_on_table_mouse_entered)
	$Parallax2D.position = table.position
	
	balls = $Rack.get_balls()
	balls.append($CueBall)
	for ball in balls:
		ball.activate.connect(_on_ball_activate)
		ball.deactivate.connect(_on_ball_deactivate)
		ball.ball_freed.connect(_on_ball_freed)
		ball.custom_mouse_entered.connect(_on_ball_mouse_entered)
	
	set_wind()
	hide_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$Camera2D/UI/CollisionLabel.text = ""
	#for i in range(len(AudioManager.ball_collisions)):
		#if AudioManager.ball_collisions[i]:
			#$Camera2D/UI/CollisionLabel.text += "[" + AudioManager.ball_collisions[i][0].name + ", " + AudioManager.ball_collisions[i][1].name + "]\n"
		#else:
			#break
	if currently_shooting:
		show_power()
		return
	power_label.hide()
	
	if cam_area.overlaps_body(table) and not resetting_camera:
		target_scale += 0.01


func _physics_process(delta: float) -> void:
	if currently_shooting:
		var mouse_pos = get_viewport().get_mouse_position()
		var screen_margin = 30
		## Previous cam scale logic: just increase target scale when cursor is within edge margin
		if mouse_pos.x < screen_margin:
			target_scale += 0.0004 * abs(mouse_pos.x - screen_margin)
		if mouse_pos.x > get_viewport_rect().size.x - screen_margin:
			target_scale += 0.0004 * abs(mouse_pos.x - get_viewport_rect().size.x)
		if mouse_pos.y < screen_margin:
			target_scale += 0.0004 * abs(mouse_pos.y - screen_margin)
		if mouse_pos.y > get_viewport_rect().size.y - screen_margin:
			target_scale += 0.0004 * abs(mouse_pos.y - get_viewport_rect().size.y)
		target_scale = clamp(target_scale, 0, 5)
		
		## New logic: linearly scale camera based on cursor distance from center of table.
		## I like the way this feels more, but still needs work. I think it should take x/y components
		## into account rather than just using vector length, because moving to the edge of the screen
		## horizontally causes a jarring snap, but vertically feels good. Calculation also can't stay
		## as originating from center of table since the table's going to move around in the actual game,
		## but this feels like a good start with a static table
		#if (camera.scale.x > cam_scale_before
				#or mouse_pos.x < screen_margin
				#or mouse_pos.x > get_viewport_rect().size.x - screen_margin
				#or mouse_pos.y < screen_margin
				#or mouse_pos.y > get_viewport_rect().size.y - screen_margin):
			#var max_dist := 3000.0
			#var min_dist := 300.0
			#var mouse_dist = (get_global_mouse_position() - table.global_position).length()
			#var calculated_scale: float
			#if mouse_dist > min_dist:
				#calculated_scale = 4 * ((mouse_dist - 300) / (3000 - 300)) + 1
				#calculated_scale = clamp(calculated_scale, 1, 5)
				#if calculated_scale < cam_scale_before:
					#calculated_scale = cam_scale_before
				#else:
					#camera.scale = Vector2(calculated_scale, calculated_scale)
			#else:
				#camera.scale = Vector2(cam_scale_before, cam_scale_before)
			#print("dist: %d\tscale: %f\t(before: %f)" % [mouse_dist, calculated_scale, cam_scale_before])
	#else:
		#camera.scale = lerp(camera.scale, Vector2(target_scale, target_scale), ZOOM_SPEED * delta)
	
	camera.scale = lerp(camera.scale, Vector2(target_scale, target_scale), ZOOM_SPEED * delta)
	camera.zoom = Vector2(1.0 / camera.scale.x, 1.0 / camera.scale.y)
	
	if camera.position != target_pos and not currently_shooting:
		camera.position = lerp(camera.position, target_pos, POS_SPEED * delta)
	
	if camera.rotation != target_rot and not currently_shooting:
		camera.rotation = lerp(camera.rotation, target_rot, ROT_SPEED * delta)
	
	if resetting_camera:
		if within(camera.scale.x, target_scale) and within(camera.position.x, target_pos.x) and within(camera.rotation, target_rot):
			resetting_camera = false
	
	## Wind (problem: table won't sleep (so cam won't reset) while wind-affected balls are acting on it)
	if wind:
		for ball:Ball in balls:
			ball.apply_central_force(wind_dir * 200)
	
	## Check here if any balls have been knocked off (through) the table


func within(a: float, b: float, t: float = 0.025) -> bool:
	## Returns true if the difference of a and b is less than a threshold t.
	## Use to compare floats
	return a - b < t


func show_power() -> void:
	if not show_shot_power:
		return
	
	var power = active_ball.get_shot_power()
	var color: Color
	
	power_label.text = str(int(power))
	if power < 20:
		# 0 strength shot (cancel): Gray
		power_label.text = "0"
		color = Color.DIM_GRAY
	elif power < 440:
		# Low strength shot: Green(0,1,0) -> Yellow(1,1,0)
		color = Color(
			(power - 20) / (439 - 40),
			1,
			0
		)
	elif power < 840:
		# Low-medium strength: Yellow(1,1,0) -> Orange(1,.5,0)
		color = Color(
			1,
			1 - (power - 440) / ((839-440) * 2),
			0
		)
	elif power < 1240:
		# Medium-high strength: Orange(1,.5,0) -> Red(1,0,0)
		color = Color(
			1,
			0.5 - (power - 840) / ((1239-840) * 2),
			0
		)
	else:
		# High strength: Red
		color = Color.RED
	
	power_label.show()
	#power_label.position = get_local_mouse_position() + Vector2(1152/2 + 10, 648/2 - 12)
	#power_label.add_theme_color_override("font_color", color)
	power_label.self_modulate = color


func set_wind() -> void:
	if wind:
		var random_rot = randf_range(0.0, 2.0 * PI)
		wind_dir = Vector2.UP.rotated(random_rot)
		$Camera2D/UI/StaticWindLabel/WindArrow.rotation = random_rot
		$Camera2D/UI/StaticWindLabel.show()
	else:
		$Camera2D/UI/StaticWindLabel.hide()


func win() -> void:
	$Table/WinLabel.show()


func show_settings() -> void:
	settings_menu.show()
	$Camera2D/UI/ShowSettingsButton.icon = MINUS_ICON


func hide_settings() -> void:
	settings_menu.hide()
	$Camera2D/UI/ShowSettingsButton.icon = GEAR_ICON


func _on_ball_activate(ball) -> void:
	active_ball = ball
	currently_shooting = true
	cam_scale_before = camera.scale.x
	target_scale = camera.scale.x


func _on_ball_deactivate() -> void:
	active_ball = null
	currently_shooting = false
	target_scale = cam_scale_before
	power_label.hide()


func _on_table_mouse_entered() -> void:
	if currently_shooting:
		target_scale = cam_scale_before


func _on_ball_mouse_entered(ball: Ball) -> void:
	if active_ball == null:
		ball.show_highlight()


func _on_ball_freed(ball: Ball) -> void:
	balls.erase(ball)
	if balls.is_empty():
		win()


func _on_table_sleeping_state_changed() -> void:
	#print('table sleep changed to ', table.sleeping)
	if table.sleeping and not currently_shooting:
		target_pos = table.position
		target_rot = table.rotation
		target_scale = 1.0
		resetting_camera = true
		#print('setting cam')


func _on_show_settings_button_pressed() -> void:
	if settings_menu.visible:
		hide_settings()
	else:
		show_settings()


func _on_music_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	var db = linear_to_db(value) * 0.85 - 28.9
	#print('setting music to ', value, "% -- ", db)
	AudioServer.set_bus_volume_db(bus_idx, db)
	$Camera2D/UI/SettingsMenu/MarginContainer/VBoxContainer/MusicHBoxContainer/PercentageLabel.text = str(value)


func _on_effects_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Effects")
	var db = linear_to_db(value) * 0.85 - 28.9
	AudioServer.set_bus_volume_db(bus_idx, db)
	$Camera2D/UI/SettingsMenu/MarginContainer/VBoxContainer/EffectsHBoxContainer2/PercentageLabel.text = str(value)


func _on_ui_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Stray left click, close settings menu
		if settings_menu.visible:
			hide_settings()


func _on_wind_check_box_toggled(toggled_on: bool) -> void:
	wind = toggled_on
	set_wind()


func _on_show_power_check_box_toggled(toggled_on: bool) -> void:
	show_shot_power = toggled_on
