class_name Equipment
extends Node

signal changed

const SLOT_KINDS := [
	Equippable.Kind.HEAD,
	Equippable.Kind.BODY,
	Equippable.Kind.LEGS,
	Equippable.Kind.ACCESSORY,
	Equippable.Kind.ACCESSORY,
]

@export var starting_items: Array[Equippable] = []

## One entry per slot in SLOT_KINDS. Null means the slot is empty.
var slots: Array[Equippable] = []


func _ready() -> void:
	slots.resize(SLOT_KINDS.size())
	for item in starting_items:
		equip(item)


## Puts the item in a matching slot, preferring an empty one.
## Returns whatever it replaced, or the item itself if no slot fits.
func equip(item: Equippable) -> Equippable:
	var index := _slot_for(item.kind)
	if index == -1:
		return item
	var previous := slots[index]
	slots[index] = item
	changed.emit()
	return previous


func unequip(index: int) -> Equippable:
	var previous := slots[index]
	slots[index] = null
	changed.emit()
	return previous


func total_defense() -> int:
	var total := 0
	for item in slots:
		if item:
			total += item.defense
	return total


func speed_multiplier() -> float:
	var multiplier := 1.0
	for item in slots:
		if item:
			multiplier += item.speed_bonus
	return multiplier


func _slot_for(kind: Equippable.Kind) -> int:
	var occupied := -1
	for index in SLOT_KINDS.size():
		if SLOT_KINDS[index] != kind:
			continue
		if slots[index] == null:
			return index
		if occupied == -1:
			occupied = index
	return occupied
