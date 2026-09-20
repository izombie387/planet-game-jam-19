extends PanelContainer

var directions := {}
var cardinal_to_dir := {
	"N": Vector2i.UP,
	"NE": Vector2i(1,-1),
	"E": Vector2i.RIGHT,
	"SE": Vector2i(1,1),
	"S": Vector2i.DOWN,
	"SW": Vector2i(-1,1),
	"W": Vector2i.LEFT,
	"NW": Vector2i(-1,-1)
}

func _ready() -> void:
	for c in $GridContainer.get_children():
		if not c is CheckButton:
			continue
		c.toggled.connect(_dir_toggled.bind(c.name))
		
func _dir_toggled(on: bool, cardinal: String) -> void:
	var dir = cardinal_to_dir[cardinal]
	if on:
		directions[dir] = true
	else:
		directions.erase(dir)
	print(directions.keys())
		
		
