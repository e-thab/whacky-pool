extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var rands = range(1, 15)
	rands.shuffle()
	
	for i in range(len(rands)):
		get_child(i).apply_number(rands[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
