class_name Block
extends Resource

@export var display_name := ""
## Damage needed to break the block.
@export var durability := 10.0
@export var fill_color := Color.WHITE
@export var edge_color := Color.BLACK
## Height in pixels of a strip painted along the top edge, like grass. 0 disables it.
@export var top_depth := 0
@export var top_color := Color.WHITE


func paint(image: Image, origin: Vector2i, size: int) -> void:
	image.fill_rect(Rect2i(origin, Vector2i(size, size)), edge_color)
	image.fill_rect(Rect2i(origin + Vector2i.ONE, Vector2i(size - 1, size - 1)), fill_color)
	if top_depth > 0:
		image.fill_rect(Rect2i(origin + Vector2i.ONE, Vector2i(size - 1, top_depth)), top_color)
