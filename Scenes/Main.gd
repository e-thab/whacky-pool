extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func zoom(n):
	$Camera2D.zoom.x += n
	$Camera2D.zoom.y += n


func _on_Area2D_body_exited(body):
	print('test')
	zoom(0.125)
