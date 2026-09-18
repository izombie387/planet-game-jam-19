class_name Character
extends Node2D

enum State { IDLE, DIGGING, MOVING }

signal started_digging(pos: Vector2i)
signal stopped_digging()

var _is_moving := false
var _current_pos := Vector2i()
var _state : State

@export var label: Label
@export var anim: AnimationPlayer
@export var map: TileMapLayer

func _ready() -> void:
	_set_state(State.IDLE)
	_current_pos = Vector2i(-2,-2)
	_move_to(_current_pos)
	anim.animation_finished.connect(_anim_finished)

func _get_input() -> Vector2i:
	var input_dir := Vector2i.ZERO
	if Input.is_action_pressed("ui_left"): input_dir = Vector2i.LEFT
	elif Input.is_action_pressed("ui_right"): input_dir = Vector2i.RIGHT
	elif Input.is_action_pressed("ui_down"): input_dir = Vector2i.DOWN
	elif Input.is_action_pressed("ui_up"): input_dir = Vector2i.UP
	
	return input_dir

func _process(_delta: float) -> void:
	var input_dir = _get_input()
	
	if input_dir == Vector2i.ZERO:
		_set_state(State.IDLE)
	elif _state == State.IDLE:
		_try_move_or_dig(input_dir)
	
func _try_move_or_dig(dir: Vector2i) -> void:
	var target_pos = _current_pos + dir
	var target_atlas_pos = map.get_cell_atlas_coords(target_pos)
	if target_atlas_pos == Vector2i(-1,-1):
		_move_to(target_pos)
	else:
		_dig_at(target_pos, target_atlas_pos)
		
func on_block_erased(pos: Vector2i) -> void:
	_done_moving()
		
func _dig_at(pos: Vector2i, atlas_pos: Vector2i) -> void:
	started_digging.emit(pos)
	_set_state(State.DIGGING)
	
func _move_to(pos: Vector2i) -> void:
	var t = create_tween()
	var new_position = map.map_to_local(pos)
	_is_moving = true
	t.tween_property(self, "position", new_position, 0.25)
	t.tween_callback(_done_moving)
	_current_pos = pos
	_set_state(State.MOVING)

func _done_moving() -> void:
	var input_dir := _get_input()
	if input_dir == Vector2i.ZERO:
		_set_state(State.IDLE)
	else:
		_try_move_or_dig(input_dir)
	
func _anim_finished(anim_name: StringName) -> void:
	pass
	#_set_state(State.IDLE)

func _set_state(new_state: State) -> void:
	var anim_name := ""
	match new_state:
		State.IDLE:
			if _state == State.DIGGING:
				stopped_digging.emit()
			anim_name = &""
		State.MOVING:
			if _state == State.DIGGING:
				stopped_digging.emit()
			anim_name = &""
		State.DIGGING:
			anim_name = &"digging"
	if anim_name:
		anim.play(anim_name)
	else:
		anim.stop()
	
	_state = new_state
	label.text = str(State.find_key(_state))
	
	
