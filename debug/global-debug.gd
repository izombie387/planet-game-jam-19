extends Node

func _toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		_toggle_fullscreen()
	elif event.is_action_pressed("reset_game"):
		get_tree().reload_current_scene()
	elif event.pressed:
		match event.keycode:
			KEY_M:
				PlayerStats.add_points_no_signal(100)
			KEY_O:
				PlayerStats.add_block(TileManager.OreType.GOLD)
