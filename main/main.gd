extends Node2D

@export var map: TileMapLayer
@export var character: Node2D

func _ready() -> void:
	map.clear()
	_generate_tiles()

func _generate_tiles() -> void:
	for x in 20:
		for y in 20:
			if randf() < 0.5:
				continue
			var rand_x = randi_range(0,7)
			var rand_y = randi_range(0,7)
			var rand_coords = Vector2i(rand_x, rand_y)
			map.set_cell(Vector2i(x,y), 0, rand_coords)
