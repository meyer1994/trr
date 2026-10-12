class_name EquipmentPanel
extends VBoxContainer

## Shows worn equipment; clicking a slot takes that piece off.

const KIND_CAPTIONS := {
	Equippable.Kind.HEAD: "Head",
	Equippable.Kind.BODY: "Body",
	Equippable.Kind.LEGS: "Legs",
	Equippable.Kind.ACCESSORY: "Acc",
}

@export var player: Player

var _slots: Array[ItemSlot] = []
var _defense_label := Label.new()


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_defense_label.add_theme_font_size_override("font_size", 12)
	add_child(_defense_label)
	for index in Equipment.SLOT_KINDS.size():
		var slot := ItemSlot.new(KIND_CAPTIONS[Equipment.SLOT_KINDS[index]], true)
		slot.set_clickable(true)
		slot.pressed.connect(player.take_off.bind(index))
		_slots.append(slot)
		add_child(slot)
	player.stats_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for index in _slots.size():
		_slots[index].set_stack(player.equipment.slots[index])
	_defense_label.text = "Defense: %d" % roundi(player.stats.value(Effect.Stat.DEFENSE))
