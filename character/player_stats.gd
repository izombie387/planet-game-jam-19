class_name PlayerStats
extends Resource

static var total_blocks_mined := 0
static var upgrade_points := 0
static var total_ore := 0
static var ore_collected: Dictionary[TileManager.OreType, int]

var move_cooldown: float
var drill_power: float
var drill_cooldown: float

static func add_block(block_type: TileManager.OreType) -> void:
	if block_type not in ore_collected:
		ore_collected[block_type] = 0
	ore_collected[block_type] += 1
	total_blocks_mined += 1
	total_ore += 1

static func pop_random_block() -> TileManager.OreType:
	if ore_collected.is_empty():
		return TileManager.OreType.NONE
	var ore = ore_collected.keys().pick_random()
	ore_collected[ore] -= 1
	if ore_collected[ore] <= 0:
		ore_collected.erase(ore)
	total_ore -= 1
	return ore

static func add_points(amount: int) -> void:
	upgrade_points += amount

func on_buff_changed(buff: Buff, _buff_state: Buff.State, _unlock_dist: int) -> void:
	set(buff.target_property, buff.current)
	print("Setting %s to %.1f" % [buff.target_property, buff.current])
