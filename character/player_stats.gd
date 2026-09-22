class_name PlayerStats
extends RefCounted

static var total_blocks_mined := 0
static var points := 0
static var total_ore := 0
static var ore_collected: Dictionary[TileManager.OreType, int]

static func _static_init() -> void:
	for ore_type in TileManager.OreType.values():
		ore_collected[ore_type] = 0
	print("ore tracking populated: %s" % ore_collected)

static func add_block(block_type: TileManager.OreType) -> void:
	if block_type not in ore_collected:
		print("%s not in ore_collected" % TileManager.OreType.find_key(block_type))
		return
	ore_collected[block_type] += 1
	total_blocks_mined += 1
	total_ore += 1

static func use_random_block() -> TileManager.OreType:
	if ore_collected.is_empty():
		return TileManager.OreType.NONE
	var ore = ore_collected.keys().pick_random()
	ore_collected[ore] -= 1
	if ore_collected[ore] <= 0:
		ore_collected.erase(ore)
	total_ore -= 1
	return ore

static func add_points(amount: int) -> void:
	points += amount
