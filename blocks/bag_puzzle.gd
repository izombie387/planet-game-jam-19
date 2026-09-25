extends Control

var _dragging_shape : OreShape
@export var map: TileMapLayer
@export var debug_cells := false
@export var spawn_point: Marker2D
@export var smelt_button: Button
@export var smelt_dialog: PanelContainer
@export var drop_button: Button
#@export var explosion_particles: GPUParticles2D
@export var close_button: Button
@export var click_handler: Control
@export var ray_cast: RayCast2D
@export var clear_button: Button
@export var points_label: Label
@export var player_stats: PlayerStats

var _cells: Dictionary[Vector2i, OreShape]
var empty_ore_shape_scene = load("res://blocks/ore-shapes/empty_ore_shape.tscn")
var rigid_shape_scene = load("res://blocks/ore-shapes/rigid_shape.tscn")

func _ready() -> void:
	click_handler.gui_input.connect(_on_handler_gui_input)
	clear_button.pressed.connect(_clear_box)
	close_button.pressed.connect(hide)
	drop_button.pressed.connect(spawn_random_rigid_shape)
	smelt_dialog.hide()
	smelt_button.pressed.connect(_smelt_pressed)
	visibility_changed.connect(_on_visibility_changed)
	
func _clear_box() -> void:
	Sfx.play(Sfx.Sound.CLICK)
	var shapes = get_tree().get_nodes_in_group("rigid_shapes")
	print("clearing ", shapes)
	for rigid in shapes:
		rigid.queue_free()
	
#func _explode_at(pos: Vector2) -> void:
	#explosion_particles.position = pos
	#if explosion_particles.emitting:
		#explosion_particles.restart()
	#explosion_particles.emitting = true
	
func _on_visibility_changed() -> void:
	if visible:
		populate_ore()
	
func populate_ore() -> void:
	var total = PlayerStats.total_ore
	drop_button.disabled = total <= 0
	drop_button.text = "Drop Ore [%d]" % total
	
func _smelt_pressed() -> void:
	var total_points := _get_point_total()
	_clear_grid()
	if total_points > 0:
		Sfx.play(Sfx.Sound.UPGRADE)
		#Sfx.play(Sfx.Sound.CLICK)
		player_stats.add_points(total_points)
		points_label.text = "+$%d" % total_points
	
func _get_point_total() -> int:
	Sfx.play(Sfx.Sound.CLICK)
	var ore_types := {}
	for ore_shape in _cells.values():
		var block_name = ore_shape.block.name
		if block_name not in ore_types:
			ore_types[block_name] = 0
		ore_types[block_name] += 1 * ore_shape.block.puzzle_points
		
	var total_cells = map.get_used_cells().size()
	var filled_cells = _cells.size()
	var percent := float(filled_cells) / float(total_cells)

	var bonus_multi := percent * 5.0
			
	var ore_points_sum = ore_types.values().reduce(func(a,c): return a+c, 0)
	var total_points = int(ore_points_sum * bonus_multi)
	var message = "\n".join([
			"%s" % (JSON.stringify(ore_types, "")
					.replace("{", "")
					.replace("}", "")
					.replace("\"", ""))
					.replace(":", "$"),
			"%.1f X Bonus (%d Percent Filled)" % [bonus_multi, percent * 100],
			"Total $ %d" % total_points
	])
	points_label.text = message
	
	return total_points
	
func _clear_grid() -> void:
	for ore_shape in _cells.values():
		ore_shape.queue_free()
	_cells.clear()
				
func spawn_random_rigid_shape(test:= false) -> void:
	if test:
		var rand_block = TileManager.get_random_block()
		var rand_poly = TileManager.get_random_polygon()
		spawn_rigid_shape(rand_block, rand_poly)
		return
		
	Sfx.play(Sfx.Sound.CLICK)
	
	var block_type = PlayerStats.pop_random_block()
	if block_type != TileManager.OreType.NONE:
		var block = TileManager.get_block_from_type(block_type)
		var poly = TileManager.get_random_polygon()
		spawn_rigid_shape(block, poly)
	
	populate_ore()

func spawn_rigid_shape(block: BlockData, poly: PackedScene) -> void:
	var rigid_shape = rigid_shape_scene.instantiate()
	rigid_shape.setup(block, poly)
	rigid_shape.pressed.connect(_on_rigid_pressed.bind(block, poly, rigid_shape))
	add_child(rigid_shape)
	rigid_shape.position = spawn_point.position
	rigid_shape.add_to_group("rigid_shapes")

func _on_rigid_pressed(block: BlockData, poly: PackedScene, body: RigidBody2D) -> void:
	Sfx.play(Sfx.Sound.CLICK)
	var new_shape: OreShape = empty_ore_shape_scene.instantiate()
	new_shape.setup(block, poly)
	add_child(new_shape)
	new_shape.area.shape_pressed.connect(_on_ore_shape_pressed)
	_pickup(new_shape)
	body.queue_free()
	
func _on_handler_gui_input(event: InputEvent) -> void:
	if not is_instance_valid(_dragging_shape):
		_dragging_shape = null
		if event.is_action_pressed("select"):
			_check_physics_click()
		return
	elif event.is_action_released("select"):
		assert(_dragging_shape)
		_drop_current_shape()
		Sfx.play(Sfx.Sound.CLICK)
	elif event.is_action_pressed("rotate_shape"):
		assert(_dragging_shape)
		_dragging_shape.rotate_90()
		Sfx.play(Sfx.Sound.CLICK)
	
func _check_physics_click() -> void:
	ray_cast.global_position = get_global_mouse_position()
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var c = ray_cast.get_collider()
		if c.has_method("press"):
			c.press()
			Sfx.play(Sfx.Sound.CLICK)
	else:
		print("no body found")

func _on_ore_shape_pressed(shape: OreShape) -> void:
	if _dragging_shape:
		return
	_pickup(shape)
	Sfx.play(Sfx.Sound.CLICK)
	_debug_show_cells()
		
func _drop_current_shape() -> void:
	Sfx.play(Sfx.Sound.CLICK)
	if _try_drop(get_global_mouse_position(), _dragging_shape):
		pass
	else:
		spawn_rigid_shape(_dragging_shape.block, _dragging_shape.polygon_scene)
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
	_get_point_total()
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
			
	_get_point_total()
		
func _process(_delta: float) -> void:
	if _dragging_shape:
		_dragging_shape.global_position = get_global_mouse_position()
		
				
