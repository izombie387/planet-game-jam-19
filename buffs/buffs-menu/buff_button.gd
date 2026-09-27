@tool
class_name BuffButton
extends PanelContainer

@export var button: Button
@export var icon: TextureRect
@export var buff_name_label: Label
@export var stat_label: Label
@export var cost_label: Label
@export var _buff: Buff :
	set(v):
		_buff = v
		if Engine.is_editor_hint() and is_node_ready():
			load_buff(v)

func load_buff(buff: Buff):
	buff.init_value()
	_populate(buff)
	icon.texture = buff.icon
	
	if not Engine.is_editor_hint():
		buff.buff_changed.connect(_on_buff_changed)

func _populate(buff: Buff):
	var buff_name = buff.display_name
	buff_name_label.text = buff_name.replace("_", " ").to_upper()
	stat_label.text = buff.get_upgrade_text()
	cost_label.text = "$%d" % buff.get_cost()
	
func _on_buff_changed(buff: Buff, buff_state: Buff.State, unlock_dist: int) -> void:
	_update(buff, buff_state, unlock_dist)
	
func _set_locked(locked: bool) -> void:
	stat_label.visible = not locked
	cost_label.visible = not locked
	icon.visible = not locked
	button.disabled = locked
	
func _update(buff: Buff, buff_state: Buff.State, unlock_dist: int) -> void:
	#print("updating %s with state %s" % [buff.resource_name, Buff.State.find_key(buff_state)])
	match buff_state:
		Buff.State.LOCKED:
			_set_locked(true)
			modulate = Color(0.8, 0.8, 0.8, 1.0)
			buff_name_label.text = "UNLOCKS IN %d" % unlock_dist
		Buff.State.CANNOT_AFFORD:
			_set_locked(false)
			modulate = Color(0.8, 0.8, 0.8, 1.0)
			cost_label.add_theme_color_override(&"font_color", Color(0.9, 0.09, 0.09, 1.0))
			_populate(buff)
		Buff.State.CAN_AFFORD:
			_set_locked(false)
			modulate = Color(1.0, 1.0, 1.0, 1.0) 
			cost_label.add_theme_color_override(&"font_color", Color(0.09, 0.9, 0.198, 1.0))
			_populate(buff)
		Buff.State.MAXED:
			_set_locked(false)
			modulate = Color(0.588, 0.588, 1.0, 1.0)
			cost_label.hide()
			_populate(buff)
			
