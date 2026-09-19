extends Node2D

@export var map: TileMapLayer
@export var character: Character
@export var digging_sprite: Sprite2D
@export var digging_timer: Timer
@export var ui: Control

var _blocks: Dictionary[Vector2i, BlockData]
var _block_healths: Dictionary[Vector2i, int]
var _current_digging_pos : Vector2i
# probably put in a player stats class
var _total_blocks_gained : int

func _ready() -> void:
	map.clear()
	_generate_tiles()
	character.started_digging.connect(_on_started_digging)
	character.stopped_digging.connect(_on_stopped_digging)
	digging_timer.timeout.connect(_on_dug)
	
func _on_dug() -> void:
	digging_sprite.flip_h = not digging_sprite.flip_h
	var new_block_health = _block_healths[_current_digging_pos] - 1
	if new_block_health <= 0:
		_gain_block_value(_blocks[_current_digging_pos])
		map.erase_cell(_current_digging_pos)
		_blocks.erase(_current_digging_pos)
		character.on_block_erased(_current_digging_pos)
		digging_sprite.hide()
	else:
		_block_healths[_current_digging_pos] = new_block_health
		digging_sprite.progress_bar.value = new_block_health
	
func _gain_block_value(block_data: BlockData) -> void:
	_total_blocks_gained += 1
	ui.update_blocks_gained(_total_blocks_gained)
	
func _on_started_digging(pos: Vector2i) -> void:
	_current_digging_pos = pos
	var block_data := _blocks[pos]
	var init_block_health := block_data.init_health
	
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
	var sample_block = load("res://blocks/block_resources/sample-block.tres")
	for x in 20:
		for y in 20:
			if randf() < 0.5:
				continue
			var rand_x = randi_range(0,7)
			var rand_y = randi_range(0,7)
			var rand_atlas_coords = Vector2i(rand_x, rand_y)
			var cell_pos = Vector2i(x,y)
			map.set_cell(cell_pos, 0, rand_atlas_coords)
			_blocks[cell_pos] = sample_block
