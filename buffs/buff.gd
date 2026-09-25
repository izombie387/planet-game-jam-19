class_name Buff extends Resource

signal buff_changed(buff: Buff, buff_state: State, unlock_dist: int)

enum IncResult { JUST_MAXED, ALREADY_MAXED, NOT_FOUND, INCREMENTED }
enum State { LOCKED, CANNOT_AFFORD, CAN_AFFORD, MAXED, NONE }
enum Target { NONE, PLAYER, MAIN, PUZZLE }

@export var display_name : String
@export var icon: DPITexture
@export var max_level: int
@export var base: float
@export var cap: float
@export var base_cost: float
@export var cost_mult: float
@export var cap_action: String
@export var format: String
@export var unlocks_at: int
@export var cap_text: String
@export var target := Target.NONE
@export var target_property : String
@export var progress_curve := 0.5

var current: float
var level: int = 0

func is_maxed() -> bool:
	return level >= max_level

func init_value() -> void:
	current = base

func get_state(player_cash: int, unlock_dist: int) -> State:
	if unlock_dist > 0:
		return State.LOCKED
	if is_maxed():
		return State.MAXED	
	if player_cash >= get_cost():
		return State.CAN_AFFORD
	return State.CANNOT_AFFORD
	
func update(total_mined: int, player_cash: int) -> void:
	var unlock_dist = unlocks_at - total_mined
	buff_changed.emit(self, get_state(player_cash, unlock_dist), unlock_dist)

func get_cost() -> int:
	return int(base_cost * pow(cost_mult, level))

func get_upgrade_text() -> String:
	var text := ""
	var current_fmt = get_formatted_val(current)
	if level < max_level:
		var next_fmt = get_formatted_val(_get_val_at_level(level + 1))
		text = "%s -> %s" % [current_fmt, next_fmt]
	else:
		text = "%s MAXED" % current_fmt
	return text
	
func _get_val_at_level(lev: int) -> float:
	var weight := float(lev) / max_level
	var curved_weight = ease(weight, progress_curve)
	return lerpf(base, cap, curved_weight)
	
func increment_buff() -> IncResult:
	if level >= max_level:
		return IncResult.ALREADY_MAXED
	
	level += 1
	current = _get_val_at_level(level)
	
	if level == max_level:
		return IncResult.JUST_MAXED
		
	return IncResult.INCREMENTED
	
func get_formatted_val(val := current) -> String:
	return format % val
	
	
