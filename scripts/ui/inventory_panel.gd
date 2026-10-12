class_name InventoryPanel
extends GridContainer

## Shows the inventory rows below the hotbar. The inventory action toggles it, and opening a chest
## shows it. While a chest is open, clicking a slot stores its stack in the chest.

@export var player: Player
@export var chests: Chests

var _slots: Array[ItemSlot] = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	columns = Player.HOTBAR_SIZE
	for index in range(Player.HOTBAR_SIZE, Player.INVENTORY_SIZE):
		var slot := ItemSlot.new()
		slot.set_clickable(true)
		slot.pressed.connect(chests.store.bind(index))
		_slots.append(slot)
		add_child(slot)
	player.inventory.changed.connect(_refresh)
	chests.opened.connect(show.unbind(1))
	hide()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("inventory"):
		return
	visible = not visible
	if not visible:
		chests.close()
	get_viewport().set_input_as_handled()


func _refresh() -> void:
	for index in _slots.size():
		_slots[index].set_stack(player.inventory.slots[Player.HOTBAR_SIZE + index])
