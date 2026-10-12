class_name EquipmentPanel
extends VBoxContainer

const KIND_CAPTIONS := {
	Equippable.Kind.HEAD: "Head",
	Equippable.Kind.BODY: "Body",
	Equippable.Kind.LEGS: "Legs",
	Equippable.Kind.ACCESSORY: "Acc",
}

@export var equipment: Equipment

var _slots: Array[ItemSlot] = []
var _defense_label := Label.new()


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_defense_label.add_theme_font_size_override("font_size", 12)
	add_child(_defense_label)
	for kind in Equipment.SLOT_KINDS:
		var slot := ItemSlot.new(KIND_CAPTIONS[kind], true)
		_slots.append(slot)
		add_child(slot)
	equipment.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for index in _slots.size():
		_slots[index].set_item(equipment.slots[index])
	var defense := EffectSet.from_items(equipment.slots).apply(Effect.Stat.DEFENSE, 0.0)
	_defense_label.text = "Defense: %d" % roundi(defense)
