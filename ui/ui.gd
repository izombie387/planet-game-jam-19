class_name UI
extends Control

enum Menu { BAG, SETTINGS, NONE, UPGRADES }
@onready var menus := {
	Menu.BAG: bag_menu,
	Menu.SETTINGS: settings_menu,
	Menu.UPGRADES: upgrades_menu,
}

@export var upgrades_menu: MarginContainer
@export var upgrade_points_label: Label
@export var ore_count_label: Label
@export var character: Character
@export var menu_button: Button
@export var settings_menu: CenterContainer
@export var bag_menu: Control
@export var bag_button: Button
@export var upgrades_button: Button


func _ready() -> void:
	upgrades_button.pressed.connect(_menu_toggled.bind(Menu.UPGRADES))
	bag_button.pressed.connect(_menu_toggled.bind(Menu.BAG))
	bag_menu.hide()
	menu_button.pressed.connect(_menu_toggled.bind(Menu.SETTINGS))
	settings_menu.hide()
	character.surfaced.connect(_toggled_on_surface.bind(true))
	character.submerged.connect(_toggled_on_surface.bind(false))
	
func _menu_toggled(menu: Menu) -> void:
	for key in menus:
		if key == menu:
			menus[key].visible = not menus[key].visible
		else:
			menus[key].visible = false
	
func _toggled_on_surface(_is_on: bool) -> void:
	pass

func _on_submerged() -> void:
	pass
	
func update_stats(upgrade_points: int, ore_count: int) -> void:
	upgrade_points_label.text = str(upgrade_points)
	ore_count_label.text = str(ore_count)
	
func get_current_menu() -> Menu:
	if bag_menu.visible:
		return Menu.BAG
	elif settings_menu.visible:
		return Menu.SETTINGS
	elif upgrades_menu.visible:
		return Menu.UPGRADES
	return Menu.NONE
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_bag"):
		settings_menu.hide()
		bag_menu.visible = not bag_menu.visible
		update_stats(PlayerStats.upgrade_points, PlayerStats.total_ore)
	
	elif event.is_action_pressed("toggle_upgrades"):
		upgrades_menu.visible = not upgrades_menu.visible
		
	elif event.is_action_pressed("ui_cancel"):
		match get_current_menu():
			Menu.NONE:
				settings_menu.show()
			Menu.BAG:
				bag_menu.hide()
				update_stats(PlayerStats.upgrade_points, PlayerStats.total_ore)
			Menu.SETTINGS:
				settings_menu.hide()
			Menu.UPGRADES:
				upgrades_menu.hide()
				
				
				
				
				
