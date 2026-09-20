extends CenterContainer

@export var close_button: Button
@export var volume_slider: HSlider

func _ready() -> void:
	close_button.pressed.connect(hide)
	volume_slider.value_changed.connect(_volume_changed.bind(0))
	
func _volume_changed(val: float, bus_idx: int) -> void:
	AudioServer.set_bus_volume_linear(bus_idx, val)
