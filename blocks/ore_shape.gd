@tool
class_name OreShape
extends Node2D

@export_tool_button("find cells") var fc = _set_cell_offsets

@export var area: Area2D
@export var cell_offsets: Array[Vector2i]
@export var collision: CollisionPolygon2D

var starting_position : Vector2

func _ready() -> void:
	starting_position = global_position
	area.input_pickable = true
	
func reset_position() -> void:
	global_position = starting_position

func _set_cell_offsets() -> void:
	var collision_poly = $Area/Collision.polygon
	var cell_size = Vector2(16,16)
	var origin = -cell_size / 2.0
	var cells: Array[Vector2i]
	for x in range(-3,3,1):
		for y in range(-3,3,1):
			var p = Vector2(x,y) * cell_size + origin
			var is_inside = Geometry2D.is_point_in_polygon(p, collision_poly)
			if is_inside:
				cells.append(Vector2i(x,y))
	cell_offsets = cells
	print("Found %d cells" % cells.size())
