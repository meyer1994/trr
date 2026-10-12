class_name Hotbar
extends HBoxContainer

## Shows the first inventory row and which slot the player holds.
## While a chest is open, clicking a slot stores its stack in the chest.

@export var player: Player
@export var chests: Chests

var _slots: Array[ItemSlot] = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	for index in Player.HOTBAR_SIZE:
		var slot := ItemSlot.new(str((index + 1) % 10))
		slot.pressed.connect(chests.store.bind(index))
		_slots.append(slot)
		add_child(slot)
	player.inventory.changed.connect(_refresh)
	player.held_changed.connect(_refresh)
	chests.opened.connect(_set_clickable.bind(true).unbind(1))
	chests.closed.connect(_set_clickable.bind(false))
	_refresh()


func _set_clickable(clickable: bool) -> void:
	for slot in _slots:
		slot.set_clickable(clickable)


func _refresh() -> void:
	for index in _slots.size():
		_slots[index].set_stack(player.inventory.slots[index])
		_slots[index].set_selected(index == player.held_index)
