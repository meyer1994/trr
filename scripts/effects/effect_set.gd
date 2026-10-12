class_name EffectSet
extends RefCounted

## Effect sources are any objects with `get_effects() -> Array[Effect]`; null entries are skipped.
## Effect targets resolve their stats with `resolve(target, base_stats())`.

## Invalid effects already reported, so each one warns only once.
static var _warned := {}

var _by_target := {}


static func from_sources(sources: Array) -> EffectSet:
	var effect_set := EffectSet.new()
	for source in sources:
		if source:
			for effect: Effect in source.get_effects():
				effect_set.add(effect)
	return effect_set


func add(effect: Effect) -> void:
	if not effect.is_valid():
		_warn_invalid(effect)
		return
	if not _by_target.has(effect.target):
		_by_target[effect.target] = []
	_by_target[effect.target].append(effect)


func resolve(target: Effect.Target, base: Dictionary) -> Stats:
	return Stats.new(base, _by_target.get(target, []))


static func _warn_invalid(effect: Effect) -> void:
	if _warned.has(effect):
		return
	_warned[effect] = true
	var source := effect.resource_path if effect.resource_path else "an unsaved resource"
	push_warning("Effect from %s is ignored: %s targets have no %s stat." % [
		source, Effect.Target.keys()[effect.target], Effect.Stat.keys()[effect.stat],
	])
