extends Node

signal win
signal update_score
signal update_combo

const MAX_SINK_VELOCITY = 2000.0
const MAX_ABILITY_SEC = 6.0
const COOLDOWN_SEC = 2.0
var ABILITY_COLOR = Color("7feb98")
var COOLDOWN_COLOR = Color("ff3e3e")

var balls = []
var sink_count = 0 # balls sunk
var score = 0
var combo = 0
var slow_time = 6.0 # amount of slow ability left
var game_seconds = 0
var cooling_down = false # if ability was completely drained (cooldown trigger)
var shooting = false # don't change camera while shooting
var win_state = false # used to not register gameplay input after win
var table_sleeping = false # for combo
var waiting_for_input = true # don't start time until first player input

var prog_bar = null
var score_label = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if win_state: return
	if Input.is_action_pressed("slow") and !cooling_down:
		decrease_slow(delta)
		update_prog_bar()
	else:
		increase_slow(delta)
		update_prog_bar()
		
	if Input.is_action_just_pressed("slow") and !cooling_down:
		set_slowmo(true)
	elif Input.is_action_just_released("slow"):
		set_slowmo(false)


func reset():
	balls = []
	sink_count = 0
	score = 0
	combo = 0
	slow_time = 6.0
	game_seconds = 0
	cooling_down = false
	shooting = false
	win_state = false
	waiting_for_input = true
	prog_bar = null
	score_label = null
	set_slowmo(false)
	get_tree().reload_current_scene()


func add_prog_bar(bar):
	prog_bar = bar
	prog_bar.self_modulate = ABILITY_COLOR
	prog_bar.max_value = MAX_ABILITY_SEC
	prog_bar.value = MAX_ABILITY_SEC


func add_score_label(label):
	score_label = label


func add_ball(ball):
	balls.append(ball)
	ball.connect("sink", self, "sink")
	#ball.connect("shooting", self, "toggle_slowmo")


func add_game_seconds(sec):
	if !win_state and !waiting_for_input:
		game_seconds += sec
		add_score(-1)


func add_combo(n):
	combo += n
	emit_signal("update_combo")


func reset_combo():
	combo = 0
	emit_signal("update_combo")


func add_score(n):
	score += n
	emit_signal("update_score")


func multiply_score(n):
	score *= n
	emit_signal("update_score")


func update_prog_bar():
	if prog_bar:
		prog_bar.value = slow_time


func decrease_slow(time):
	slow_time = max(slow_time - (1.0 / Engine.time_scale * time), 0.0)
	if slow_time == 0:
		cool_down()


func increase_slow(time):
	slow_time = min(slow_time + (1.0 / Engine.time_scale * time), MAX_ABILITY_SEC)


func cool_down():
	cooling_down = true
	prog_bar.self_modulate = COOLDOWN_COLOR
	set_slowmo(false)
	yield(get_tree().create_timer(COOLDOWN_SEC), "timeout")
	cooling_down = false
	prog_bar.self_modulate = ABILITY_COLOR


func sink():
	add_score(1 + combo)
	
	sink_count += 1
	if sink_count >= len(balls):
		emit_signal("win")
		win_state = true
		set_slowmo(false)
		#score = abs(score - game_seconds)
	
	if !table_sleeping:
		add_combo(1)


func set_shooting(state):
	shooting = state


func set_slowmo(on):
	if on:
		Engine.time_scale = 0.125
	else:
		Engine.time_scale = 1


func set_table_sleep_state(state):
	table_sleeping = state
	if table_sleeping:
		reset_combo()
