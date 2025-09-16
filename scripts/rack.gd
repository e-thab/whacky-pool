@tool
extends Node2D

var has_assigned_numbers: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		randomize()
		var rands = range(1, 16)
		rands.shuffle()
		for i in range(15):
			get_child(i).set_ball_number(rands[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint() and !has_assigned_numbers:
		var i = 1
		for child: Ball in get_children():
			child.get_node("Sprite2D").texture = load("res://assets/sprites/%d.png" % i)
			i += 1
		has_assigned_numbers = true


func get_balls() -> Array[Node]:
	return get_children()
