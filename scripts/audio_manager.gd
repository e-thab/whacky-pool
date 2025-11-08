extends Node

enum Sound {
	BALL_HIT,
	TABLE_HIT,
	POCKET
}

# A 2D array of reported collision pairs. Since both balls report when a
# collision happens, the pair of colliding bodies are added to this array on
# the first report, then on the second report, the pair is found and removed
# from this array to avoid double-reporting. This is only needed for ball-ball
# collisions as the table does not monitor for contacts, so ball-table
# collisions are already only reported once.
var ball_collisions: Array = []
var elapsed: float = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta
	#if elapsed >= 2.0:
		#print(ball_collisions)
		#elapsed = 0
	pass


func report_collision(body1: RigidBody2D, body2: RigidBody2D):
	if elapsed < 1: return
	var db_scale: float = 1
	var high_v: float = 800.0
	var min_v: float = 12.0
	var velocity: float
	var ball: Ball
	
	if body1.name == "Table" or body2.name == "Table":
		#print('collision: ', body1.name, ' -> ', body2.name, ' LINEAR v = ', max(body1.linear_velocity.length(), body2.linear_velocity.length()))
		if body1.name == "Table":
			ball = body2
		else:
			ball = body1
		
		velocity = ball.last_velocity
		if velocity >= min_v:
			db_scale = (velocity - min_v) / (high_v - min_v)
			ball.play_sound(Sound.TABLE_HIT, db_scale)
		return
	
	for collision in ball_collisions:
		if body1 in collision and body2 in collision:
			ball_collisions.erase(collision)
			return
	
	#print('collision: ', body1, ' -> ', body2, ' last_v = ', max(body1.last_velocity, body2.last_velocity))
	ball_collisions.append([body1, body2])
	ball = body1
	velocity = max(body1.last_velocity, body2.last_velocity)
	
	if velocity >= min_v:
		db_scale = (velocity - min_v) / (high_v - min_v)
		ball.play_sound(Sound.BALL_HIT, db_scale)
