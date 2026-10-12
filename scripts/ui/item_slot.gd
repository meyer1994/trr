class_name ItemSlot
extends Panel

const SIZE := Vector2(40, 40)
const BACKGROUND_COLOR := Color(0, 0, 0, 0.5)
const BORDER_COLOR := Color(1, 1, 1, 0.25)
const SELECTED_BORDER_COLOR := Color(1, 0.85, 0.2)

## Icons are drawn at twice their pixel size inside this margin.
const ICON_MARGIN := 4.0

var _style := StyleBoxFlat.new()
var _icon := TextureRect.new()
var _swatch := ColorRect.new()
var _label := Label.new()
var _caption_only_when_empty := false


func _init(caption := "", caption_only_when_empty := false) -> void:
	_caption_only_when_empty = caption_only_when_empty
	custom_minimum_size = SIZE
	mouse_filter = MOUSE_FILTER_IGNORE
	_style.bg_color = BACKGROUND_COLOR
	_style.border_color = BORDER_COLOR
	_style.set_border_width_all(2)
	add_theme_stylebox_override("panel", _style)

	_icon.mouse_filter = MOUSE_FILTER_IGNORE
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.set_anchors_and_offsets_preset(PRESET_FULL_RECT, PRESET_MODE_MINSIZE, int(ICON_MARGIN))
	add_child(_icon)

	_swatch.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_swatch)

	_label.text = caption
	_label.position = Vector2(4, 0)
	_label.add_theme_font_size_override("font_size", 10)
	add_child(_label)
	set_stack(null)


func set_stack(stack: ItemStack) -> void:
	var item := stack.item if stack else null
	_icon.visible = item != null and item.icon != null
	_swatch.visible = item != null and item.icon == null
	_label.visible = item == null or not _caption_only_when_empty
	if item:
		_icon.texture = item.icon
		_swatch.color = item.icon_color
		_swatch.size = item.icon_size
		_swatch.position = (SIZE - item.icon_size) / 2


func set_selected(selected: bool) -> void:
	_style.border_color = SELECTED_BORDER_COLOR if selected else BORDER_COLOR
