extends CenterContainer

@export var close_button: Button
@export var volume_slider: HSlider

func _ready() -> void:
	close_button.pressed.connect(hide)
	volume_slider.value_changed.connect(_volume_changed.bind(0))

#func _process(delta: float) -> void:
	# NOTE moved this logic to ui.gd
	# the menu appear if escape key is pressed
	#if (Input.is_action_just_pressed("ui_cancel")):
		#visible = not visible

func _volume_changed(val: float, bus_idx: int) -> void:
	AudioServer.set_bus_volume_linear(bus_idx, val)
