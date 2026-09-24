extends ColorRect

@export var ray_cast: RayCast2D
var dragging := false
	
func _gui_input(event: InputEvent) -> void:
	if dragging:
		return
	if event.is_action_pressed("select"):
		ray_cast.global_position = get_global_mouse_position()
		ray_cast.force_raycast_update()
		if ray_cast.is_colliding():
			var c = ray_cast.get_collider()
			if c is RigidShape:
				c.press()
		else:
			print("no body found")
