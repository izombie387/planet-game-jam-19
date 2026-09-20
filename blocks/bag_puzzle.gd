extends Control

#const HALF_CELL := Vector2(8,8)
var _dragging_shape : Node2D
@export var ore_container: Control
@export var map: TileMapLayer
var _cells: Dictionary[Vector2i, OreShape]

func _ready() -> void:
	var ore_shapes = ore_container.get_children()
	for ore_shape: Node2D in ore_shapes:
		ore_shape.area.input_event.connect(_on_area_input.bind(ore_shape))

func _on_area_input(_vp: Node, event: InputEvent, _idx: int, ore_shape: Node2D) -> void:
	if event.is_action_pressed("select"):
		assert(not _dragging_shape)
		_pickup(ore_shape)
		ore_shape.starting_position = ore_shape.global_position
		_dragging_shape = ore_shape
		_dragging_shape.modulate.a = 0.75
		_dragging_shape.z_index += 10
		
	elif event.is_action_released("select"):
		if not _dragging_shape == ore_shape:
			return
		if _try_drop(get_global_mouse_position(), _dragging_shape):
			pass
		else:
			_dragging_shape.reset_position()
			_try_drop(_dragging_shape.global_position, _dragging_shape)
		_dragging_shape.modulate.a = 1.0
		_dragging_shape.z_index -= 10
		_dragging_shape = null
		
func _try_drop(drop_pos: Vector2, shape: OreShape) -> bool:
	assert(shape)
	if not shape:
		return false
	var origin = map.local_to_map(drop_pos)
	var grid = map.get_used_cells()
	for offset: Vector2i in shape.cell_offsets:
		var c = origin + offset
		if map.get_cell_source_id(c) == -1:
			return false
		if c in _cells:
			return false
			
	for offset: Vector2i in shape.cell_offsets:
		var c = origin + offset
		_cells[c] = shape
		
	shape.global_position = map.map_to_local(origin)
	return true
	
func _pickup(shape: OreShape) -> void:
	var origin = map.local_to_map(shape.global_position)
	for offset: Vector2i in shape.cell_offsets:
		var c = origin + offset
		if _cells.get(c) == shape:
			_cells.erase(c)
		
func _process(_delta: float) -> void:
	if _dragging_shape:
		_dragging_shape.global_position = get_global_mouse_position()
