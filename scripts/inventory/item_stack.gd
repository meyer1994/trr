class_name ItemStack
extends RefCounted

## The copy of an item the player owns. Per-copy state belongs here, never on the shared Item.

var item: Item
var count := 1


func _init(stack_item: Item, stack_count := 1) -> void:
	item = stack_item
	count = stack_count


func get_effects() -> Array[Effect]:
	return item.effects
