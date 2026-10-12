class_name Item
extends Resource

@export var display_name := ""
@export var icon_color := Color.WHITE
@export var icon_size := Vector2(16, 16)
## Granted to the player while the item is worn or held.
@export var effects: Array[Effect] = []


## The item's own stats, which effects targeting it can modify.
func base_stats() -> Dictionary:
	return {}
