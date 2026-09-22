extends Control

var _dragging_shape : OreShape
@export var ore_pickers: VBoxContainer
@export var map: TileMapLayer
@export var debug_cells := false
@export var spawn_point: Marker2D
@export var smelt_button: Button
@export var smelt_dialog: PanelContainer
@export var drop_button: Button

var _cells: Dictionary[Vector2i, OreShape]
var empty_ore_shape_scene = load("res://blocks/ore-shapes/empty_ore_shape.tscn")
var rigid_shape_scene = load("res://blocks/ore-shapes/rigid_shape.tscn")

func _ready() -> void:
	drop_button.pressed.connect(spawn_random_rigid_shape)
	smelt_dialog.hide()
	smelt_button.pressed.connect(_smelt_pressed)
	
func populate_ore() -> void:
	drop_button.text = "Drop Ore [%d]" % PlayerStats.total_ore
	
func _smelt_pressed() -> void:
	var total_cells = map.get_used_cells().size()
	var filled_cells = _cells.size()
	var percent = (filled_cells / float(total_cells)) * 100.0
	var bonus_multi:= 0.5
	match percent:
		var x when x > 99:
			bonus_multi = 5.0
		var x when x > 75:
			bonus_multi = 2.0
		var x when x > 10:
			bonus_multi = 1.1
		_:
			pass
	#var fill_points = filled_cells * 0.1
	var total_points = int(filled_cells * bonus_multi)
	var message = "\n".join([
			"%d percent full" % percent,
			"%d spaces filled" % filled_cells,
			"%.1fx multi" % bonus_multi,
			"total points = %d" % total_points
	])
	smelt_dialog.label.text = message
	smelt_dialog.show()
	_clear_grid()
	PlayerStats.add_points(total_points)
	
func _clear_grid() -> void:
	for ore_shape in _cells.values():
		ore_shape.queue_free()
	_cells.clear()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		spawn_rigid_shape(null, null)

func spawn_random_rigid_shape(test:= false) -> void:
	if test:
		var rand_block = TileManager.get_random_block()
		var rand_poly = TileManager.get_random_polygon()
		spawn_rigid_shape(rand_block, rand_poly)
		return
		
	var block_type = PlayerStats.use_random_block()
	var block = TileManager.get_block_from_type(block_type)
	var poly = TileManager.get_random_polygon()
	spawn_rigid_shape(block, poly)
	

func spawn_rigid_shape(block: BlockData, poly: PackedScene) -> void:
	var rigid_shape = rigid_shape_scene.instantiate()
	rigid_shape.setup(block, poly)
	rigid_shape.pressed.connect(_on_rigid_pressed.bind(block, poly, rigid_shape))
	add_child(rigid_shape)
	rigid_shape.position = spawn_point.position

func _on_rigid_pressed(block: BlockData, poly: PackedScene, body: RigidBody2D) -> void:
	var new_shape: OreShape = empty_ore_shape_scene.instantiate()
	new_shape.setup(block, poly)
	add_child(new_shape)
	new_shape.area.input_event.connect(_on_ore_shape_input.bind(new_shape))
	_pickup(new_shape)
	body.queue_free()
		
func _on_picker_pressed(ore_shape_scene: PackedScene, button: Button) -> void:
	button.set_pressed_no_signal(false)
	var new_shape: OreShape = ore_shape_scene.instantiate()
	add_child(new_shape)
	new_shape.area.input_event.connect(_on_ore_shape_input.bind(new_shape))
	_pickup(new_shape)

func _on_ore_shape_input(_vp: Node, event: InputEvent, _idx: int, shape: OreShape) -> void:
	if event.is_action_pressed("select"):
		if _dragging_shape:
			return
		_pickup(shape)
		
		_debug_show_cells()
		
func _unhandled_input(event: InputEvent) -> void:
	if not _dragging_shape:
		return
		
	if event.is_action_released("select"):
		_drop_current_shape()
	elif event.is_action_pressed("rotate_shape"):
		_dragging_shape.rotate_90()
		
func _drop_current_shape() -> void:
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
		
func _debug_show_cells() -> void:
	if not debug_cells:
		return
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
		
				
