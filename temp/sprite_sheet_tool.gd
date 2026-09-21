@tool
extends Node2D

@export_tool_button("generate") var _gen_btn = generate

@export var tex_rect: TextureRect
@export var textures : Array[Texture2D]

func generate() -> void:
	var columns := 8
	var rows := 2
	
	var drawable: DrawableTexture2D = tex_rect.texture
	var cell_px = int(TileManager.CELL_SIZE.x)
	drawable.setup(columns * cell_px, rows * cell_px, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0.0, 0.0, 0.0, 0.0))
	
	for i: int in textures.size():
		var tex = textures[i]
		
		var col := i % columns
		var row := i / columns
		var pos := Vector2(col, row) * TileManager.CELL_SIZE.x
		var rect := Rect2i(pos, TileManager.CELL_SIZE)
		
		drawable.blit_rect(rect, tex)
		
	var image: Image = drawable.get_image()
	var png_path: String = "res://art/blocks-sheet.png"
	var err := image.save_png(png_path)
	
	if err == OK:
		print("saved to ", png_path)
		if Engine.is_editor_hint():
			EditorInterface.get_resource_filesystem().scan()
		
