extends Sprite2D

@export var progress_bar: ProgressBar
@export var hp_label: Label

func _ready() -> void:
	hide()
	self_modulate.a = 0.0
	
func animate(hp_total: int, duration := 0.1) -> void:
	hp_label.text = str(hp_total)
	hp_label.rotation = randf_range(-0.1, 0.1)
	var t := create_tween()
	t.tween_property(self, "self_modulate:a", 1.0, duration)
	t.tween_property(self, "self_modulate:a", 0.0, duration)
	
	
