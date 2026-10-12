class_name ItemContainer
extends RefCounted

## A fixed number of slots holding item stacks, such as the player's inventory or a chest.

signal changed

## Null means the slot is empty.
var slots: Array[ItemStack] = []


func _init(size: int) -> void:
	slots.resize(size)


## Puts the stack in the first free slot. Returns false when every slot is taken.
func add(stack: ItemStack) -> bool:
	var index := slots.find(null)
	if index == -1:
		return false
	put(index, stack)
	return true


## Removes and returns the stack in a slot, or null if it was empty.
func take(index: int) -> ItemStack:
	var stack := slots[index]
	if stack:
		slots[index] = null
		changed.emit()
	return stack


func put(index: int, stack: ItemStack) -> void:
	slots[index] = stack
	changed.emit()


## Moves the stack in a slot into the first free slot of another container.
## Does nothing when the slot is empty or the other container is full.
func move_to(index: int, other: ItemContainer) -> void:
	var stack := slots[index]
	if stack and other.add(stack):
		take(index)
