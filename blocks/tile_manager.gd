class_name TileManager
extends RefCounted

var rng := RandomNumberGenerator.new()
var _block_weights := PackedFloat32Array()
var _blocks : Array[BlockData]
var _walls : Array[BlockData]

const RESOURCES : Array[BlockData] = [
	preload("res://blocks/block_resources/stone.tres"),
	preload("res://blocks/block_resources/rock.tres"),
	preload("res://blocks/block_resources/pillar.tres")
]

func _init() -> void:
	load_resources()

func load_resources() -> void:
	for block in RESOURCES:
		if block.is_wall:
			_walls.append(block)
		else:
			_blocks.append(block)
			var weight = maxf(float(block.drop_rate), 1.0)
			_block_weights.append(weight)
	
func get_random_block() -> BlockData:
	var idx := rng.rand_weighted(_block_weights)
	var block = _blocks[idx]
	return block
	
func get_wall() -> BlockData:
	return _walls[0]
