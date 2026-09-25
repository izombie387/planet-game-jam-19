class_name TileManager
extends RefCounted

enum OreType {
	DIAMOND=0, EMERALD=1, GOLD=2, IRON=3, 
	STONE=4, NONE=6, DIRT=7,
}

static var rng := RandomNumberGenerator.new()
static var _block_weights := PackedFloat32Array()
static var _poly_weights := PackedFloat32Array()
static var _block_types : Array[BlockData]
static var _wall_types : Array[BlockData]

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
	
static func get_wall() -> BlockData:
	return _wall_types[0]
