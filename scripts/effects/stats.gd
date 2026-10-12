class_name Stats
extends RefCounted

## Effects already reported for targeting a stat their scope doesn't have.
static var _warned := {}

var _values := {}


## Flat bonuses are added first, then all percentages are summed and applied once.
func _init(scope: Effect.Scope, base: Dictionary, effects: Array) -> void:
	var flat := {}
	var percent := {}
	for effect: Effect in effects:
		if not base.has(effect.stat):
			_warn_unsupported(scope, effect)
			continue
		var totals := flat if effect.mode == Effect.Mode.FLAT else percent
		totals[effect.stat] = totals.get(effect.stat, 0.0) + effect.value
	for stat in base:
		_values[stat] = (base[stat] + flat.get(stat, 0.0)) * (1.0 + percent.get(stat, 0.0))


func value(stat: Effect.Stat) -> float:
	return _values.get(stat, 0.0)


static func _warn_unsupported(scope: Effect.Scope, effect: Effect) -> void:
	if _warned.has(effect):
		return
	_warned[effect] = true
	var source := effect.resource_path if effect.resource_path else "an unsaved resource"
	push_warning("Effect from %s does nothing: %s targets have no %s stat." % [
		source, Effect.Scope.keys()[scope], Effect.Stat.keys()[effect.stat],
	])
