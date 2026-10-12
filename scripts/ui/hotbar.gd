class_name Hotbar
extends HBoxContainer

## Shows the first inventory row and which slot the player holds.

@export var player: Player

var _slots: Array[ItemSlot] = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	for index in Inventory.HOTBAR_SIZE:
		var slot := ItemSlot.new(str((index + 1) % 10))
		_slots.append(slot)
		add_child(slot)
	player.inventory.changed.connect(_refresh)
	player.held_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for index in _slots.size():
		_slots[index].set_stack(player.inventory.slots[index])
		_slots[index].set_selected(index == player.held_index)
