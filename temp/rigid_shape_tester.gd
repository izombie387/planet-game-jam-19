extends Node2D

var rigid_shape_scene = preload("res://blocks/ore-shapes/rigid_shape.tscn")

#func _ready() -> void:
	#var _tm = TileManager.new()

func _spawn_random_shape() -> void:
	var poly := TileManager.get_random_polygon()
	
	var rigid_shape: RigidShape = rigid_shape_scene.instantiate()
	add_child(rigid_shape)
	rigid_shape.setup(TileManager.get_random_block(), poly)
	rigid_shape.position = Vector2(250,10)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_spawn_random_shape()
