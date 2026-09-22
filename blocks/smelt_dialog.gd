extends PanelContainer

@export var label: Label
@export var button: Button

func _ready() -> void:
	button.pressed.connect(hide)
