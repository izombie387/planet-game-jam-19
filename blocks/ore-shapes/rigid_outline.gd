extends Node2D

var polygon: PackedVector2Array

func _draw() -> void:
	if polygon.is_empty():
		print("no poly")
		return
	polygon.append(polygon[0])
	draw_polyline(polygon, Color(0.37, 0.279, 0.177, 1.0), 2.0)
	
