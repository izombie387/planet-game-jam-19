extends Control

var _dragging_shape : OreShape
@export var ore_pickers: VBoxContainer
@export var map: TileMapLayer
var _cells: Dictionary[Vector2i, OreShape]

func _ready() -> void:
	for picker_button: Button in ore_pickers.get_children():
		picker_button.pressed.connect(_on_picker_pressed.bind(picker_button.ore_shape_scene))
		
func _on_picker_pressed(ore_shape_scene: PackedScene) -> void:
	var new_shape: OreShape = ore_shape_scene.instantiate()
	add_child(new_shape)
	new_shape.area.input_event.connect(_on_ore_shape_input.bind(new_shape))
	_pickup(new_shape)

func _on_ore_shape_input(_vp: Node, event: InputEvent, _idx: int, shape: OreShape) -> void:
	if event.is_action_pressed("select"):
		if _dragging_shape:
			return
		#assert(not _dragging_shape)
		_pickup(shape)
		
		_debug_show_cells()
		
	elif event.is_action_released("select"):
		if not _dragging_shape == shape:
			return
		if _try_drop(get_global_mouse_position(), _dragging_shape):
			pass
		else:
			_dragging_shape.queue_free()
			_dragging_shape = null
			return

		_dragging_shape.modulate.a = 1.0
		_dragging_shape.z_index -= 10
		_dragging_shape = null
		
		_debug_show_cells()
		
	elif event.is_action_pressed("rotate_shape"):
		if not _dragging_shape:
			return
		_dragging_shape.rotate_90()
		
func _debug_show_cells() -> void:
	for cell in map.get_used_cells():
		if cell in _cells:
			map.set_cell(cell, 0, Vector2i(2,0))
		else:
			map.set_cell(cell, 0, Vector2i(0,1))
		
func _try_drop(drop_pos: Vector2, shape: OreShape) -> bool:
	assert(shape)
	if not shape:
		return false
	var origin = map.local_to_map(drop_pos)
	
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
	_dragging_shape = shape
	_dragging_shape.modulate.a = 0.75
	_dragging_shape.z_index += 10
	
	var origin = map.local_to_map(shape.global_position)
	for offset: Vector2i in shape.cell_offsets:
		var c = origin + offset
		if _cells.get(c) == shape:
			_cells.erase(c)
		
func _process(_delta: float) -> void:
	if _dragging_shape:
		_dragging_shape.global_position = get_global_mouse_position()
		
				
