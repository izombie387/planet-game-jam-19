class_name BuffsPanel
extends PanelContainer

@export var buffs_label: Label
@export var upgrades_container: VBoxContainer
@export var button_scene: PackedScene
@export var buff_arr : Array[Buff]
@export var player_stats: PlayerStats

func _ready() -> void:
	for placeholder in get_tree().get_nodes_in_group("placeholder"):
		placeholder.queue_free()
	load_buffs()
		
func load_buffs() -> void:
	buff_arr.sort_custom(func(a: Buff, b: Buff):
				return a.unlocks_at < b.unlocks_at)
				
	for buff: Buff in buff_arr:
		var new_button: BuffButton = button_scene.instantiate()
		new_button.load_buff(buff)
		new_button.button.pressed.connect(_on_buff_pressed.bind(buff))
		upgrades_container.add_child(new_button)
		
		match buff.target:
			Buff.Target.PLAYER:
				if not buff.buff_changed.is_connected(player_stats.on_buff_changed):
					buff.buff_changed.connect(player_stats.on_buff_changed)
			Buff.Target.MAIN:
				pass
			Buff.Target.PUZZLE:
				pass
				
	_update_buffs()
	
func _update_buffs() -> void:
	for buff: Buff in buff_arr:
		buff.update(PlayerStats.total_blocks_mined, PlayerStats.upgrade_points)
	
func _on_buff_pressed(buff: Buff) -> void:
	var buff_cost = buff.get_cost()
	if buff.is_maxed():
		return
	if PlayerStats.upgrade_points < buff_cost:
		Sfx.play(Sfx.Sound.CLUNK)
		return
	match buff.increment_buff():
		Buff.IncResult.NOT_FOUND:
			return
		Buff.IncResult.INCREMENTED:
			Sfx.play(Sfx.Sound.CLAP)
			Sfx.play(Sfx.Sound.UPGRADE)
		Buff.IncResult.JUST_MAXED:
			Sfx.play(Sfx.Sound.LOCK)
			Sfx.play(Sfx.Sound.UPGRADE)
			var cap_action_name := buff.cap_action
			if cap_action_name:
				var cap_action := Callable(self, cap_action_name)
				if cap_action.is_valid():
					cap_action.call()
				
	PlayerStats.upgrade_points -= buff_cost
	buff.update(PlayerStats.total_blocks_mined, PlayerStats.upgrade_points)
		
		
