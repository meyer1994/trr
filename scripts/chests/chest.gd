class_name Chest
extends Sprite2D

## Where in the world a chest is, which decides its loot table.
enum Band { SURFACE, CAVE, ISLAND }

const CLOSED_TEXTURE := preload("res://chests/chest_closed.png")
const OPEN_TEXTURE := preload("res://chests/chest_open.png")

var cell: Vector2i
var band: Band
var is_open := false:
	set(value):
		is_open = value
		texture = OPEN_TEXTURE if value else CLOSED_TEXTURE


## The chest's origin is the bottom middle of its sprite, so it sits on the cell's floor.
func _init(chest_cell: Vector2i, chest_band: Band) -> void:
	cell = chest_cell
	band = chest_band
	is_open = false
	centered = false
	offset = Vector2(-texture.get_width() / 2.0, -texture.get_height())
