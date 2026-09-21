class_name RigidShape
extends RigidBody2D

@export var collision: CollisionPolygon2D
@export var outline: Node2D

func setup(ore_type: TileManager.OreType, polygon_scene: PackedScene) -> void:
	var poly = polygon_scene.instantiate() as Polygon2D
	add_child(poly)
	poly.texture = TileManager.TEXTURES[ore_type]
	poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	collision.polygon = poly.polygon
	
	outline.polygon = poly.polygon
	outline.queue_redraw()
