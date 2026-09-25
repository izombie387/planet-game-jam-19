class_name TileManager
extends RefCounted

enum OreType {
	DIAMOND=0, EMERALD=1, GOLD=2, IRON=3, 
	STONE=4, NONE=6, DIRT=7, TREE=8,
}
enum Function {
	BLOCK=0, WALL=1, SPECIAL_BLOCK=2, NONE=3
}

static var _blocks_by_function := {
	Function.BLOCK : Array(),
	Function.WALL : Array(),
	Function.SPECIAL_BLOCK : Array(),
}

static var rng := RandomNumberGenerator.new()
static var _block_weights := PackedFloat32Array()
static var _poly_weights := PackedFloat32Array()

#static var _block_types : Array[BlockData]
#static var _wall_types : Array[BlockData]
#static var _special_types : Array[BlockData]

static var _blocks : Dictionary[Vector2i, BlockData]
static var world_bounds : Vector2i

const EMPTY_RATIO := 0.2
const CELL_SIZE := Vector2(16,16)
const HALF_CELL := Vector2(8,8)
static var WALL : BlockData = load("res://blocks/block_resources/pillar.tres")
static var RESOURCES : Dictionary[OreType, BlockData] = {
	OreType.DIAMOND: load("res://blocks/block_resources/diamond.tres"),
	OreType.EMERALD: load("res://blocks/block_resources/emerald.tres"),
	OreType.GOLD: load("res://blocks/block_resources/gold.tres"),
	OreType.IRON: load("res://blocks/block_resources/iron.tres"),
	OreType.STONE: load("res://blocks/block_resources/stone.tres"),
	OreType.DIRT: load("res://blocks/block_resources/dirt.tres"),
	OreType.TREE: load("res://blocks/block_resources/tree.tres"),
}

const TOTAL_POLYS = 12

static func get_random_polygon() -> PackedScene:
	var i = rng.rand_weighted(_poly_weights)
	var path = "res://blocks/ore-shapes/polygons/poly_%d.tscn" % i
	var poly = load(path)
	assert(poly, "no poly at %d" % i)
	return poly

static func _static_init() -> void:
	_poly_weights = range(2 + TOTAL_POLYS, 2, -1)
	load_resources()
	
static func setup(p_world_bounds: Vector2i) -> void:
	world_bounds = p_world_bounds

static func get_block_from_local(map: TileMapLayer, position: Vector2) -> BlockData:
	var coords = map.local_to_map(position)
	return _blocks.get(coords)

static func get_block_from_type(block_type: TileManager.OreType) -> BlockData:
	return RESOURCES.get(block_type)

static func get_block(coords: Vector2i) -> BlockData:
	return _blocks.get(coords)
	
static func erase_block(coords: Vector2i) -> void:
	_blocks.erase(coords)
	
static func set_block(block: BlockData, coords: Vector2i) -> void:
	_blocks[coords] = block

static func set_tree(coords: Vector2i) -> void:
	var tree_block = _blocks_by_function[Function.SPECIAL_BLOCK].get(0)
	assert(tree_block)
	_blocks[coords] = tree_block
	
#static func set_block_from_type(type: OreType, coords: Vector2i) -> void:
	#var block = get_block_from_type(type)
	#set_block(block, coords)

static func load_resources() -> void:
	for block in RESOURCES.values():
		match block.function:
			Function.BLOCK:
				var weight = maxf(float(block.drop_rate), 1.0)
				_block_weights.append(weight)
			Function.WALL:
				pass
			Function.SPECIAL_BLOCK:
				pass
				
		_blocks_by_function[block.function].append(block)
		
static func get_random_block() -> BlockData:
	var idx := rng.rand_weighted(_block_weights)
	var block = _blocks_by_function[Function.BLOCK][idx]
	return block
	
static func get_wall() -> BlockData:
	return _blocks_by_function[Function.WALL][0]
