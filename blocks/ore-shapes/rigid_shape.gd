class_name RigidShape
extends RigidBody2D

signal pressed()

@export var collision: CollisionPolygon2D
@export var outline: Node2D
#var block : BlockData
#var polygon_scene : PackedScene

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		pressed.emit()

func setup(block: BlockData, polygon_scene: PackedScene) -> void:
	#block = p_block
	#polygon_scene = p_polygon_scene
	#
	var poly = polygon_scene.instantiate() as Polygon2D
	outline.add_child(poly)
	poly.texture = block.texture
	poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	collision.polygon = poly.polygon
	
	outline.polygon = poly.polygon
	outline.color = block.get_outline_color()
	outline.queue_redraw()
