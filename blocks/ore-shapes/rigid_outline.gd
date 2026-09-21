extends Node2D

var polygon: PackedVector2Array
var color: Color

func _draw() -> void:
	if polygon.is_empty():
		print("no poly")
		return
	polygon.append(polygon[0])
	draw_polyline(polygon, color, 2.0)
	
