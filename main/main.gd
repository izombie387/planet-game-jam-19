extends Node2D

@export var map: TileMapLayer
@export var character: Character
@export var digging_sprite: Sprite2D
@export var digging_timer: Timer

var _blocks: Dictionary[Vector2i, BlockData]
var _block_healths: Dictionary[Vector2i, int]
var _current_digging_pos : Vector2i

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
		map.erase_cell(_current_digging_pos)
		_blocks.erase(_current_digging_pos)
		character.on_block_erased(_current_digging_pos)
	else:
		_block_healths[_current_digging_pos] = new_block_health
	
func _on_started_digging(pos: Vector2i) -> void:
	digging_sprite.position = map.map_to_local(pos)
	digging_sprite.show()
	
	var block_data := _blocks[pos]
	var init_block_health = block_data.init_health
	_block_healths[pos] = init_block_health
	
	_current_digging_pos = pos
	_block_healths[_current_digging_pos] = init_block_health
	
	digging_timer.start()
	print("starting dig timer")
	
func _on_stopped_digging() -> void:
	digging_timer.stop()
	digging_sprite.hide()
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
