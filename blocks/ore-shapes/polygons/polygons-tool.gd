@tool
extends Node2D

@export_tool_button("show origins") var _so_tool = _show_origins
@export_tool_button("save as scenes") var _sas_tool = _save_as_scenes
var _origins: Array[Vector2]

func _show_origins() -> void:
	_origins.clear()
	for poly: Polygon2D in get_children():
		_origins.append(poly.position - TileManager.HALF_CELL)
	queue_redraw()
	
func _draw() -> void:
	for point in _origins:
		draw_circle(point, 2.0, Color.BLUE)

func _save_as_scenes() -> void:
	var children = get_children()
	for i in children.size():
		var poly := children[i] as Polygon2D
		if not poly or poly.polygon.is_empty():
			continue
		
		var poly_copy := poly.duplicate() as Polygon2D
		poly_copy.owner = poly_copy
		poly_copy.position = Vector2.ZERO
		poly_copy.color = Color.WHITE

		var scene := PackedScene.new()
		var pack_err := scene.pack(poly_copy)
		
		if pack_err == OK:
			var filename := "res://blocks/ore-shapes/polygons/poly_%d.tscn" % i
			var save_err := ResourceSaver.save(scene, filename)
			
			if save_err == OK:
				print("saved to ", filename)
			else:
				print("save error " % save_err)
		else:
			print("pack error")

		poly_copy.queue_free()
		
