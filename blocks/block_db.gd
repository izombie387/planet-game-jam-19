extends Resource

var _blocks: Dictionary[Vector2i, BlockData]

func get_block_data(pos: Vector2i) -> BlockData:
	return _blocks.get(pos)
