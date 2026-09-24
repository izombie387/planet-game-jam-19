extends Node2D

@export var map: TileMapLayer
@export var character: Character
@export var digging_sprite: Sprite2D
@export var digging_timer: Timer
@export var ui: UI
@export var explosion_particles: GPUParticles2D
@export var player_stats: PlayerStats

var _block_healths: Dictionary[Vector2i, int]
var _current_digging_pos : Vector2i

func _ready() -> void:
	Sfx.start_music()
	
	TileManager.setup(Vector2i(20,20))
	var half_width := floori(TileManager.world_bounds.x / 2.0)
	
	character.started_digging.connect(_on_started_digging)
	character.stopped_digging.connect(_on_stopped_digging)
	character.teleport(Vector2i(half_width, TileManager.world_bounds.y))
	
	digging_timer.timeout.connect(_on_dug)
	character.setup(map)
	
	map.clear()
	_generate_tiles()
	
func _explode_at(pos: Vector2) -> void:
	explosion_particles.position = pos
	if explosion_particles.emitting:
		explosion_particles.restart()
	explosion_particles.emitting = true
	
func _on_dug() -> void:
	digging_sprite.flip_h = not digging_sprite.flip_h
	var new_block_health = _block_healths[_current_digging_pos] - maxi(1, int(player_stats.drill_power))
	if new_block_health <= 0:
		var block = TileManager.get_block(_current_digging_pos)
		_gain_block_value(block)
		map.erase_cell(_current_digging_pos)
		TileManager.erase_block(_current_digging_pos)
		character.on_block_erased(_current_digging_pos)
		digging_sprite.hide()
		_explode_at(map.map_to_local(_current_digging_pos))
	else:
		Sfx.play(Sfx.Sound.TICK)
		_block_healths[_current_digging_pos] = new_block_health
		digging_sprite.progress_bar.value = new_block_health
	
func _gain_block_value(block_data: BlockData) -> void:
	PlayerStats.add_block(block_data.ore_type)
	ui.update_stats(PlayerStats.upgrade_points, PlayerStats.total_ore)
	
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
	
	character.particles.emitting = true
	character.particles.speed_scale = player_stats.drill_cooldown / 3.0
	digging_timer.wait_time = player_stats.drill_cooldown
	digging_timer.start()
	Sfx.play(Sfx.Sound.TICK)
	
func _on_stopped_digging() -> void:
	character.particles.emitting = false
	digging_timer.stop()
	
func _generate_tiles() -> void:
	var cell_pos : Vector2i
	for x in TileManager.world_bounds.x:
		for y in TileManager.world_bounds.y:
			if randf() < TileManager.EMPTY_RATIO:
				continue
			cell_pos = Vector2i(x,y)
			var random_block := TileManager.get_random_block()
			map.set_cell(cell_pos, 0, random_block.atlas_coords)
			TileManager.set_block(random_block, cell_pos)
			
	var top = -1
	var bottom = TileManager.world_bounds.y
	var left = -1
	var right = TileManager.world_bounds.x
	var wall = TileManager.WALL
	var ground_atlas_coords = Vector2i(6,0)
	
	for x in range(-1, right + 1):
		cell_pos = Vector2i(x, bottom)
		map.set_cell(cell_pos, 0, ground_atlas_coords)
		
		cell_pos = Vector2i(x, top)
		map.set_cell(cell_pos, 0, wall.atlas_coords)
		TileManager.set_block(wall, cell_pos)
		
	for y in bottom:
		cell_pos = Vector2i(left, y)
		map.set_cell(cell_pos, 0, wall.atlas_coords)
		TileManager.set_block(wall, cell_pos)

		cell_pos = Vector2i(right, y)
		map.set_cell(cell_pos, 0, wall.atlas_coords)
		TileManager.set_block(wall, cell_pos)
		
