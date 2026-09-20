extends Control

@export var blocks_gained_label: Label
@export var character: Character
@export var menu_button: Button
@export var menu: CenterContainer


func _ready() -> void:
	character.surfaced.connect(_toggled_on_surface.bind(true))
	character.submerged.connect(_toggled_on_surface.bind(false))
	menu_button.pressed.connect(_show_menu)
	
func _show_menu() -> void:
	menu.show()
	
func _toggled_on_surface(is_on: bool) -> void:
	#upgrade_menu_button.visible = is_on
	pass

func _on_submerged() -> void:
	pass
	
func update_blocks_gained(total: int) -> void:
	blocks_gained_label.text = "%d" % total
