@tool
class_name OreShape
extends Node2D

## Root node is -8,-8 position
## this is just so editing the poly line snaps correctly
## shouldn't have any negative effect when instantitated

@export_tool_button("find cells") var fc = _find_cells
@export_tool_button("transfer polygon") var tp = _transfer_polygon

@export var area: Area2D
@export var cell_offsets: Array[Vector2i]
@export var collision: CollisionPolygon2D
@export var poly: Polygon2D
@export var _debug_draw_cells := false
@export var outline: Node2D

var starting_position : Vector2

var debug_rotated_polygon

func _ready() -> void:
	_find_cells()
	_transfer_polygon()
	starting_position = global_position
	area.input_pickable = true
	
func setup(block: BlockData, polygon_scene: PackedScene) -> void:
	poly = polygon_scene.instantiate() as Polygon2D
	outline.add_child(poly)
	poly.texture = block.texture
	poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	collision.polygon = poly.polygon
	
	outline.polygon = poly.polygon
	outline.color = block.get_outline_color()
	outline.queue_redraw()
	
func rotate_90() -> void:
	rotation += angle_difference(rotation, rotation + PI / 2.0)
	_rotate_cell_offsets()
	
func _draw() -> void:
	if not _debug_draw_cells:
		return
		
	if cell_offsets:
		for c in cell_offsets:
			var rect = Rect2(
					Vector2(c) * TileManager.CELL_SIZE - TileManager.CELL_SIZE / 2.0, 
					TileManager.CELL_SIZE * 1.2)
			draw_rect(rect, Color(0.0, 0.357, 1.0, 1.0))
			
	if debug_rotated_polygon:
		draw_polyline(debug_rotated_polygon, Color.YELLOW, 1.0)
	if poly.polygon:
		draw_polyline(poly.polygon, Color.WHITE, 4.0)
	
func _transfer_polygon() -> void:
	collision.polygon = poly.polygon
	
func reset_position() -> void:
	global_position = starting_position

func _rotate_cell_offsets() -> void:
	cell_offsets.assign(cell_offsets.map(func(c): return Vector2i(-c.y, c.x)))

func _find_cells() -> void:
	if not poly.polygon:
		assert(false)
		return

	var cells: Array[Vector2i]
	for x in range(-3,3):
		for y in range(-3,3):
			var check_point = Vector2(x - 0.5, y - 0.5) * TileManager.CELL_SIZE
			if Geometry2D.is_point_in_polygon(check_point, poly.polygon):
				cells.append(Vector2i(x,y))
				
	cell_offsets = cells

	if _debug_draw_cells:
		queue_redraw()
		
