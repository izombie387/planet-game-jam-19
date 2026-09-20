class_name Character
extends Node2D

enum State { IDLE, DIGGING, MOVING }

signal surfaced()
signal submerged()
signal started_digging(pos: Vector2i, block: BlockData)
signal stopped_digging()

const DIRECTION_ROTATIONS: Dictionary[Vector2i, float] = {
	Vector2i.LEFT: PI,
	Vector2i.RIGHT: 0.0,
	Vector2i.UP: PI * 1.5,
	Vector2i.DOWN: PI * 0.5
}
const ACTION_DIRECTIONS: Dictionary[StringName, Vector2i] = {
	&"ui_left": Vector2i.LEFT,
	&"ui_right": Vector2i.RIGHT,
	&"ui_up": Vector2i.UP,
	&"ui_down": Vector2i.DOWN
}

var _input_stack : Array[StringName]
var _current_pos := Vector2i()
var _state : State
var tile_manager : TileManager
var _on_surface := true

@export var particles: GPUParticles2D
@export var particle_gradient: Gradient
@export var sprite: AnimatedSprite2D
@export var label: Label
@export var anim: AnimationPlayer
@export var map: TileMapLayer

func _ready() -> void:
	_set_state(State.IDLE)
	sprite.play()

func setup(p_map: TileMapLayer, p_tile_manager: TileManager) -> void:
	map = p_map
	tile_manager = p_tile_manager

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_echo():
		for action in ACTION_DIRECTIONS:
			if event.is_action_pressed(action):
				if not _input_stack.has(action):
					_input_stack.append(action)
			elif event.is_action_released(action):
				_input_stack.erase(action)
				
		_check_movement()
			
func _get_input() -> Vector2i:
	for i in range(_input_stack.size() - 1, -1, -1):
		var action = _input_stack[i]
		if not Input.is_action_pressed(action):
			_input_stack.remove_at(i)

	if not _input_stack.is_empty():
		var newest_action: String = _input_stack.back()
		return ACTION_DIRECTIONS[newest_action]
	
	return Vector2i.ZERO
	
func _check_movement() -> void:
	if _state == State.MOVING:
		return
		
	var input_dir = _get_input()
	
	if input_dir == Vector2i.ZERO:
		_set_state(State.IDLE)
	else:
		_try_move_or_dig(input_dir)
	
func _try_move_or_dig(dir: Vector2i) -> void:
	sprite.rotation = DIRECTION_ROTATIONS[dir]
	var target_pos = _current_pos + dir
	if target_pos.y > tile_manager.world_bounds.y:
		_set_state(State.DIGGING)
		surfaced.emit()
		_on_surface = true
		return
	elif _on_surface:
		submerged.emit()
		_on_surface = false
	var block = tile_manager.get_block(target_pos)
	if not block:
		_move_to(target_pos)
	else:
		_dig_at(target_pos, block)
		
func on_block_erased(_pos: Vector2i) -> void:
	_done_moving()
		
func _dig_at(pos: Vector2i, block: BlockData) -> void:
	started_digging.emit(pos, block)
	_set_state(State.DIGGING)
	if not block.is_wall:
		particle_gradient.colors = block.get_particles_colors()
	
func teleport(pos: Vector2i) -> void:
	var new_position = map.map_to_local(pos)
	position = new_position
	_current_pos = pos
	
func _move_to(pos: Vector2i) -> void:
	var t = create_tween()
	var new_position = map.map_to_local(pos)
	t.tween_property(self, "position", new_position, 0.25)
	t.tween_callback(_done_moving)
	_current_pos = pos
	_set_state(State.MOVING)
	
	label.text = "%s" % pos

func _done_moving() -> void:
	var input_dir := _get_input()
	if input_dir == Vector2i.ZERO:
		_set_state(State.IDLE)
	else:
		_try_move_or_dig(input_dir)

func _set_state(new_state: State) -> void:
	var anim_name := ""
	match new_state:
		State.IDLE:
			if _state == State.DIGGING:
				stopped_digging.emit()
			anim_name = &"default"
		State.MOVING:
			if _state == State.DIGGING:
				stopped_digging.emit()
			anim_name = &"default"
		State.DIGGING:
			anim_name = &"digging"
	if anim_name:
		sprite.animation = anim_name
	else:
		anim.stop()

	_state = new_state
	
	
