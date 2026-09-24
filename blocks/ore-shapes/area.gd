extends Area2D

signal shape_pressed(my_shape: OreShape)
var my_shape: OreShape

func press() -> void:
	shape_pressed.emit(my_shape)
