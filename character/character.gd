extends Node2D

var _is_moving := false
var _current_pos := Vector2i()
@export var map: TileMapLayer

func _ready() -> void:
	_current_pos = Vector2i(-2,-2)
	_move_to(_current_pos)

func _process(_delta: float) -> void:
	if _is_moving: 
		return
	var input_dir := Vector2i.ZERO
	if Input.is_action_pressed("ui_left"): input_dir = Vector2i.LEFT
	elif Input.is_action_pressed("ui_right"): input_dir = Vector2i.RIGHT
	elif Input.is_action_pressed("ui_down"): input_dir = Vector2i.DOWN
	elif Input.is_action_pressed("ui_up"): input_dir = Vector2i.UP
	
	if input_dir != Vector2i.ZERO:
		_try_move_or_dig(input_dir)
	
func _try_move_or_dig(dir: Vector2i) -> void:
	var target_pos = _current_pos + dir
	var target_atlas_pos = map.get_cell_atlas_coords(target_pos)
	if target_atlas_pos == Vector2i(-1,-1):
		_move_to(target_pos)
	else:
		_dig_at(target_pos, target_atlas_pos)
		
func _dig_at(pos: Vector2i, atlas_pos: Vector2i) -> void:
	pass
	
func _move_to(pos: Vector2i) -> void:
	var t = create_tween()
	var new_position = map.map_to_local(pos)
	_is_moving = true
	t.tween_property(self, "position", new_position, 0.25)
	t.tween_callback(_done_moving)
	_current_pos = pos

func _done_moving() -> void:
	_is_moving = false
	
	
	
