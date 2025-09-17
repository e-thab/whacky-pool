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
	## TODO: use linear interpolation instead of quiet/mid/loud db scale
	if elapsed < 1: return
	#print('collision: ', body1.name, ' -> ', body2.name, ' at ', elapsed)
	var db_scale: float = 1
	
	if body1.name == "Table" or body2.name == "Table":
		var ball: Ball
		if body1.name == "Table":
			ball = body2
		else:
			ball = body1
		
		if ball.linear_velocity.length() > 220:
			db_scale = 1
		elif ball.linear_velocity.length() > 40:
			db_scale = 0
		elif ball.linear_velocity.length() > 9:
			db_scale = 0.6
		ball.play_sound(Sound.TABLE_HIT, db_scale)
		return
	
	for collision in ball_collisions:
		if body1 in collision and body2 in collision:
			ball_collisions.erase(collision)
			return
	
	ball_collisions.append([body1, body2])
	var velocity = max(body1.linear_velocity.length(), body2.linear_velocity.length())
	var ball: Ball = body1
	if velocity > 220:
		db_scale = 1
	elif velocity > 40:
		db_scale = 0
	elif velocity > 9:
		db_scale = 0.6
	ball.play_sound(Sound.BALL_HIT, db_scale)
