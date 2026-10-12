class_name Health
extends Node

signal changed(current: int, maximum: int)
signal died

@export var max_health := 100

var current := 0
## Subtracted from every hit; a hit always deals at least 1.
var defense := 0


func _ready() -> void:
	current = max_health


func take_damage(amount: int) -> void:
	if amount <= 0 or current == 0:
		return
	current = maxi(current - maxi(amount - defense, 1), 0)
	changed.emit(current, max_health)
	if current == 0:
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0:
		return
	current = mini(current + amount, max_health)
	changed.emit(current, max_health)


func reset() -> void:
	current = max_health
	changed.emit(current, max_health)
