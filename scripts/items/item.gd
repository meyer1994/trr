class_name Item
extends Resource

@export var display_name := ""
@export var icon_color := Color.WHITE
@export var icon_size := Vector2(16, 16)
## Applied to the player while the item is worn or held.
@export var effects: Array[Effect] = []


func get_effects() -> Array[Effect]:
	return effects
