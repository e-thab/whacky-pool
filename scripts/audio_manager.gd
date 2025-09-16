extends Node

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
	#elapsed += delta
	#if elapsed >= 2.0:
		#print(ball_collisions)
		#elapsed = 0
	pass


func report_collision(body1: RigidBody2D, body2: RigidBody2D):
	print('collision: ', body1.name, ' -> ', body2.name)
	if body1.name == "Table" or body2.name == "Table":
		print('table collision')
		return
	
	var already_reported = false
	for collision in ball_collisions:
		if body1.id in collision and body2 in collision:
			ball_collisions.erase(collision)
			already_reported = true
			print('duplicate report')
			print(ball_collisions)
			break
	if not already_reported and max(body1.linear_velocity.length(), body2.linear_velocity.length()) > 10:
			ball_collisions.append([body1, body2])
			print('new collision')
			print(ball_collisions)
