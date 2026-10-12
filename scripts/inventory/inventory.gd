class_name Inventory
extends Node

signal changed

const SIZE := 40
## The first slots double as the hotbar.
const HOTBAR_SIZE := 10

@export var starting_items: Array[Item] = []

## Null means the slot is empty.
var slots: Array[ItemStack] = []


func _ready() -> void:
	slots.resize(SIZE)
	for index in mini(starting_items.size(), SIZE):
		if starting_items[index]:
			slots[index] = ItemStack.new(starting_items[index])


## Puts the stack in the first free slot. Returns false when the inventory is full.
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
