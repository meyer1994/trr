class_name Item
extends Resource

@export var display_name := ""
## Shown in inventory and equipment slots. Without one, a rectangle of icon_color and icon_size is drawn.
@export var icon: Texture2D
@export var icon_color := Color.WHITE
@export var icon_size := Vector2(16, 16)
## Drawn in the player's hand while the item is held.
@export var held_texture: Texture2D
## Pixel of held_texture that sits in the player's hand.
@export var held_grip := Vector2.ZERO
## Granted to the player while the item is worn or held.
@export var effects: Array[Effect] = []


## The item's own stats, which effects targeting it can modify.
func base_stats() -> Dictionary:
	return {}
