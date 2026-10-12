class_name Hotbar
extends HBoxContainer

signal selection_changed

const SLOT_COUNT := 10
const SLOT_KEYS: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]

@export var items: Array[Item] = []

var selected_index := 0
var selected_item: Item:
	get:
		return items[selected_index] if selected_index < items.size() else null

var _slots: Array[ItemSlot] = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	for index in SLOT_COUNT:
		var slot := ItemSlot.new(str((index + 1) % 10))
		slot.set_item(items[index] if index < items.size() else null)
		_slots.append(slot)
		add_child(slot)
	_refresh_selection()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var index := SLOT_KEYS.find(event.physical_keycode)
	if index != -1:
		selected_index = index
		_refresh_selection()
		selection_changed.emit()
		get_viewport().set_input_as_handled()


func _refresh_selection() -> void:
	for index in _slots.size():
		_slots[index].set_selected(index == selected_index)
