extends Node2D
@export var polygon: PackedVector2Array
@export var color: Color

func _draw() -> void:
	var p = polygon.duplicate()
	p.append(p[0])
	draw_polyline(p, color, 2.0)
	
