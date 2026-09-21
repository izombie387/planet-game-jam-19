class_name BlockData
extends Resource

@export var name := ""
@export var init_health := 5
@export var atlas_coords := Vector2i()
@export var drop_rate := 1
@export var is_wall := false
@export var particle_color_inner := Color(1.0, 0.65, 0.65)
@export var particle_color_outter := Color(0.36, 0.234, 0.234)
@export var texture: Texture2D

func get_outline_color() -> Color:
	return particle_color_outter

func get_particles_colors() -> PackedColorArray:
	return PackedColorArray([particle_color_inner, particle_color_outter])
	
	
