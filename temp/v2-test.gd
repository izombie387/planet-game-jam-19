extends Node2D

func _ready() -> void:
	var v := Vector2.ONE
	print(v[0])
	print(v[1])
	#print(v[-1])
	#print(v[2])
	v.max_axis_index()
