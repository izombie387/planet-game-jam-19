extends Node2D
@export var poly: Polygon2D
@export var outline_color: Color

func _draw() -> void:
	var p = poly.polygon.duplicate()
	p.append(p[0])
	draw_polyline(p, outline_color, 2.0)
	
