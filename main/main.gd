extends Node2D

@export var map: TileMapLayer
@export var character: Character
@export var digging_sprite: Sprite2D
@export var digging_timer: Timer
@export var ui: Control

var _block_healths: Dictionary[Vector2i, int]
var _current_digging_pos : Vector2i
# probably put in a player stats class
var _total_blocks_gained : int
var tile_manager := TileManager.new()

var _mine_bounds := Vector2i(20,20)

func _ready() -> void:
	map.clear()
	_generate_tiles()
	character.started_digging.connect(_on_started_digging)
	character.stopped_digging.connect(_on_stopped_digging)
	var half_width := floori(_mine_bounds.x / 2.0)
	character.teleport(Vector2i(half_width, -1))
	digging_timer.timeout.connect(_on_dug)
	tile_manager.setup(map)
	character.tile_manager = tile_manager
	
func _on_dug() -> void:
	digging_sprite.flip_h = not digging_sprite.flip_h
	var new_block_health = _block_healths[_current_digging_pos] - 1
	if new_block_health <= 0:
		var block = tile_manager.get_block(_current_digging_pos)
		_gain_block_value(block)
		map.erase_cell(_current_digging_pos)
		tile_manager.erase_block(_current_digging_pos)
		character.on_block_erased(_current_digging_pos)
		digging_sprite.hide()
	else:
		_block_healths[_current_digging_pos] = new_block_health
		digging_sprite.progress_bar.value = new_block_health
	
func _gain_block_value(_block_data: BlockData) -> void:
	_total_blocks_gained += 1
	ui.update_blocks_gained(_total_blocks_gained)
	
func _on_started_digging(pos: Vector2i, block: BlockData) -> void:
	_current_digging_pos = pos
	if block.is_wall:
		return
		
	var init_block_health := block.init_health
	
	digging_sprite.position = map.map_to_local(pos)
	digging_sprite.show()
	var p: ProgressBar = digging_sprite.progress_bar
	p.max_value = init_block_health
	
	if pos not in _block_healths:
		_block_healths[_current_digging_pos] = init_block_health
		p.value = init_block_health
	else:
		p.value = _block_healths[_current_digging_pos]
	
	digging_timer.start()
	print("starting dig timer")
	
func _on_stopped_digging() -> void:
	digging_timer.stop()
	print("  stopping dig timer")
	
func _generate_tiles() -> void:
	var cell_pos : Vector2i
	for x in _mine_bounds.x:
		for y in _mine_bounds.y:
			if randf() < 0.5:
				continue
			cell_pos = Vector2i(x,y)
			var random_block := tile_manager.get_random_block()
			map.set_cell(cell_pos, 0, random_block.atlas_coords)
			tile_manager.set_block(random_block, cell_pos)
			
	#var top = -1
	var bottom = _mine_bounds.y
	var left = -1
	var right = _mine_bounds.x
	var wall = tile_manager.get_wall()
	for x in range(-1, right + 1):
		cell_pos = Vector2i(x, bottom)
		map.set_cell(cell_pos, 0, wall.atlas_coords)
		tile_manager.set_block(wall, cell_pos)
		
	for y in bottom:
		cell_pos = Vector2i(left, y)
		map.set_cell(cell_pos, 0, wall.atlas_coords)
		tile_manager.set_block(wall, cell_pos)

		cell_pos = Vector2i(right, y)
		map.set_cell(cell_pos, 0, wall.atlas_coords)
		tile_manager.set_block(wall, cell_pos)
		
