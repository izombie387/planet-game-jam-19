extends Control

enum Menu { BAG, SETTINGS, NONE }
@onready var menus := {
	Menu.BAG: bag_menu,
	Menu.SETTINGS: settings_menu,
}

@export var blocks_gained_label: Label
@export var character: Character
@export var menu_button: Button
@export var settings_menu: CenterContainer
@export var bag_menu: Control
@export var bag_button: Button

func _ready() -> void:
	bag_button.pressed.connect(_menu_requested.bind(Menu.BAG))
	bag_menu.hide()
	menu_button.pressed.connect(_menu_requested.bind(Menu.SETTINGS))
	settings_menu.hide()
	character.surfaced.connect(_toggled_on_surface.bind(true))
	character.submerged.connect(_toggled_on_surface.bind(false))
	
func _menu_requested(menu: Menu) -> void:
	for key in menus:
		menus[key].visible = key == menu
	
func _toggled_on_surface(is_on: bool) -> void:
	pass

func _on_submerged() -> void:
	pass
	
func update_blocks_gained(total: int) -> void:
	blocks_gained_label.text = "%d" % total
	
func get_current_menu() -> Menu:
	if bag_menu.visible:
		return Menu.BAG
	elif settings_menu.visible:
		return Menu.SETTINGS
	return Menu.NONE
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_bag"):
		settings_menu.hide()
		bag_menu.visible = not bag_menu.visible
		
	elif event.is_action_pressed("ui_cancel"):
		match get_current_menu():
			Menu.NONE:
				settings_menu.show()
			Menu.BAG:
				bag_menu.hide()
			Menu.SETTINGS:
				settings_menu.hide()
