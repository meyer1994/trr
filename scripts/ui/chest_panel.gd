class_name ChestPanel
extends GridContainer

## Shows the open chest's slots. Clicking one moves its stack into the inventory.

@export var chests: Chests

var _slots: Array[ItemSlot] = []
var _container: ItemContainer


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	columns = Player.HOTBAR_SIZE
	for index in Chests.SLOT_COUNT:
		var slot := ItemSlot.new()
		slot.set_clickable(true)
		slot.pressed.connect(chests.retrieve.bind(index))
		_slots.append(slot)
		add_child(slot)
	chests.opened.connect(_on_opened)
	chests.closed.connect(_on_closed)
	hide()


func _on_opened(chest: Chest) -> void:
	_container = chests.contents(chest)
	_container.changed.connect(_refresh)
	_refresh()
	show()


func _on_closed() -> void:
	_container.changed.disconnect(_refresh)
	_container = null
	hide()


func _refresh() -> void:
	for index in _slots.size():
		_slots[index].set_stack(_container.slots[index])
