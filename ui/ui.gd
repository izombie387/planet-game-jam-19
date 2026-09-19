extends Control

@export var blocks_gained_label: Label

func update_blocks_gained(total: int) -> void:
	blocks_gained_label.text = "%d" % total
