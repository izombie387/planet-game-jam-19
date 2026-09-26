extends Node2D

@export var progress_bar: ProgressBar
@export var hp_label: Label
@export var color_rect: ColorRect

func _ready() -> void:
	hide()
	self_modulate.a = 0.0
	
func animate(hp_total: int, block: BlockData, duration := 0.075) -> void:
	match block.function:
		TileManager.Function.SPECIAL_BLOCK:
			color_rect.scale = Vector2(6.25, 6.25)
		_:
			color_rect.scale = Vector2.ONE
	hp_label.text = str(hp_total)
	hp_label.rotation = randf_range(-0.1, 0.1)
	var t := create_tween()
	t.tween_property(color_rect, "self_modulate:a", 1.0, duration)
	t.tween_property(color_rect, "self_modulate:a", 0.0, duration)
	
	
