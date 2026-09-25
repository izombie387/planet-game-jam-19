extends Sprite2D

@export var progress_bar: ProgressBar

func _ready() -> void:
	hide()
	self_modulate.a = 0.0
	
func animate(duration := 0.1) -> void:
	var t := create_tween()
	t.tween_property(self, "self_modulate:a", 1.0, duration)
	t.tween_property(self, "self_modulate:a", 0.0, duration)
	
	
