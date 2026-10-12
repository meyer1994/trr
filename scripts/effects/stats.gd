class_name Stats
extends RefCounted

var _values := {}


## Flat bonuses are added first, then all percentages are summed and applied once.
## Effects on stats this target lacks are skipped, e.g. a damage bonus while holding boots.
func _init(base: Dictionary, effects: Array) -> void:
	var flat := {}
	var percent := {}
	for effect: Effect in effects:
		if not base.has(effect.stat):
			continue
		var totals := flat if effect.mode == Effect.Mode.FLAT else percent
		totals[effect.stat] = totals.get(effect.stat, 0.0) + effect.value
	for stat in base:
		_values[stat] = (base[stat] + flat.get(stat, 0.0)) * (1.0 + percent.get(stat, 0.0))


func value(stat: Effect.Stat) -> float:
	return _values.get(stat, 0.0)
