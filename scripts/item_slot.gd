class_name ItemSlot
extends Panel

const SIZE := Vector2(40, 40)
const BACKGROUND_COLOR := Color(0, 0, 0, 0.5)
const BORDER_COLOR := Color(1, 1, 1, 0.25)
const SELECTED_BORDER_COLOR := Color(1, 0.85, 0.2)

var _style := StyleBoxFlat.new()
var _icon := ColorRect.new()
var _label := Label.new()


func _init(caption := "") -> void:
	custom_minimum_size = SIZE
	mouse_filter = MOUSE_FILTER_IGNORE
	_style.bg_color = BACKGROUND_COLOR
	_style.border_color = BORDER_COLOR
	_style.set_border_width_all(2)
	add_theme_stylebox_override("panel", _style)

	_icon.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_icon)

	_label.text = caption
	_label.position = Vector2(4, 0)
	_label.add_theme_font_size_override("font_size", 10)
	add_child(_label)
	set_item(null)


func set_item(item: Item) -> void:
	_icon.visible = item != null
	if item:
		_icon.color = item.icon_color
		_icon.size = item.icon_size
		_icon.position = (SIZE - item.icon_size) / 2


func set_selected(selected: bool) -> void:
	_style.border_color = SELECTED_BORDER_COLOR if selected else BORDER_COLOR
