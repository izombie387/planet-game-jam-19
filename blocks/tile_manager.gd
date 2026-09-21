class_name TileManager
extends RefCounted

enum OreType { DIAMOND, EMERALD, GOLD, IRON, STONE, PILLAR }

const TEXTURES := {
	OreType.DIAMOND: preload("res://art/blocks/diamond.png"),
	OreType.EMERALD: preload("res://art/blocks/emrald.png"),
	OreType.GOLD: preload("res://art/blocks/gold.png"),
	OreType.IRON: preload("res://art/blocks/iron.png"),
	OreType.STONE: preload("res://art/blocks/stone_block.png"),
}

static var rng := RandomNumberGenerator.new()
static var _block_weights := PackedFloat32Array()
static var _block_types : Array[BlockData]
static var _wall_types : Array[BlockData]

var _blocks : Dictionary[Vector2i, BlockData]
var map : TileMapLayer
var world_bounds : Vector2i

const CELL_SIZE := Vector2(16,16)
const HALF_CELL := Vector2(8,8)
const WALL : BlockData = preload("res://blocks/block_resources/pillar.tres")
const RESOURCES : Dictionary[OreType, BlockData] = {
	OreType.DIAMOND: preload("res://blocks/block_resources/diamond.tres"),
	OreType.EMERALD: preload("res://blocks/block_resources/emerald.tres"),
	OreType.GOLD: preload("res://blocks/block_resources/gold.tres"),
	OreType.IRON: preload("res://blocks/block_resources/iron.tres"),
	OreType.STONE: preload("res://blocks/block_resources/stone.tres"),
}

#const RESOURCES : Array[BlockData] = [
	#preload("res://blocks/block_resources/stone.tres"),
	#preload("res://blocks/block_resources/rock.tres"),
	#preload("res://blocks/block_resources/pillar.tres")
#]

static func get_random_polygon() -> PackedScene:
	var i = randi_range(0,17)
	var path = "res://blocks/ore-shapes/polygons/poly_%d.tscn" % i
	return load(path)

static func _static_init() -> void:
	load_resources()
	
func setup(current_map: TileMapLayer, p_world_bounds: Vector2i) -> void:
	map = current_map
	world_bounds = p_world_bounds

func get_block_from_local(position: Vector2) -> BlockData:
	var coords = map.local_to_map(position)
	return _blocks.get(coords)

func get_block(coords: Vector2i) -> BlockData:
	return _blocks.get(coords)
	
func erase_block(coords: Vector2i) -> void:
	_blocks.erase(coords)
	
func set_block(block: BlockData, coords: Vector2i) -> void:
	_blocks[coords] = block

static func load_resources() -> void:
	for block in RESOURCES.values():
		if block.is_wall:
			_wall_types.append(block)
		else:
			_block_types.append(block)
			var weight = maxf(float(block.drop_rate), 1.0)
			_block_weights.append(weight)
	
static func get_random_block() -> BlockData:
	var idx := rng.rand_weighted(_block_weights)
	var block = _block_types[idx]
	return block
	
func get_wall() -> BlockData:
	return _wall_types[0]
