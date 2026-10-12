class_name Equippable
extends Item

enum Kind { HEAD, BODY, LEGS, ACCESSORY }

@export var kind := Kind.HEAD
@export var defense := 0


func base_stats() -> Dictionary:
	return {Effect.Stat.DEFENSE: float(defense)}
