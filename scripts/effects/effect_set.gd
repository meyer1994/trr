class_name EffectSet
extends RefCounted

var _flat := {}
var _percent := {}


static func from_items(items: Array) -> EffectSet:
	var effect_set := EffectSet.new()
	for item: Item in items:
		if item:
			for effect in item.effects:
				effect_set.add(effect)
	return effect_set


func add(effect: Effect) -> void:
	var totals := _flat if effect.mode == Effect.Mode.FLAT else _percent
	totals[effect.stat] = totals.get(effect.stat, 0.0) + effect.value


## Flat bonuses are added first, then all percentages are summed and applied once.
func apply(stat: Effect.Stat, base: float) -> float:
	return (base + _flat.get(stat, 0.0)) * (1.0 + _percent.get(stat, 0.0))
