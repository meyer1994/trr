class_name Hotbar
extends HBoxContainer

const SLOT_COUNT := 10
const SLOT_SIZE := Vector2(40, 40)
const SLOT_KEYS: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]
const BACKGROUND_COLOR := Color(0, 0, 0, 0.5)
const BORDER_COLOR := Color(1, 1, 1, 0.25)
const SELECTED_BORDER_COLOR := Color(1, 0.85, 0.2)

@export var items: Array[Item] = []

var selected_index := 0
var selected_item: Item:
	get:
		return items[selected_index] if selected_index < items.size() else null

var _slot_styles: Array[StyleBoxFlat] = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	for index in SLOT_COUNT:
		add_child(_build_slot(index))
	_refresh_selection()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var index := SLOT_KEYS.find(event.physical_keycode)
	if index != -1:
		selected_index = index
		_refresh_selection()
		get_viewport().set_input_as_handled()


func _build_slot(index: int) -> Control:
	var style := StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.set_border_width_all(2)
	_slot_styles.append(style)

	var slot := Panel.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.mouse_filter = MOUSE_FILTER_IGNORE
	slot.add_theme_stylebox_override("panel", style)

	var item: Item = items[index] if index < items.size() else null
	if item:
		var icon := ColorRect.new()
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		icon.color = item.icon_color
		icon.size = item.icon_size
		icon.position = (SLOT_SIZE - icon.size) / 2
		slot.add_child(icon)

	var label := Label.new()
	label.text = str((index + 1) % 10)
	label.position = Vector2(4, 0)
	label.add_theme_font_size_override("font_size", 10)
	slot.add_child(label)
	return slot


func _refresh_selection() -> void:
	for index in _slot_styles.size():
		_slot_styles[index].border_color = SELECTED_BORDER_COLOR if index == selected_index else BORDER_COLOR
