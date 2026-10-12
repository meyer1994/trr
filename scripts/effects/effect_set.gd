class_name EffectSet
extends RefCounted

## Effect sources are any objects with `get_effects() -> Array[Effect]`; null entries are skipped.
## Effect targets resolve their own stats with `resolve(TARGET_SCOPE, base_stats())`.

var _by_scope := {}


static func from_sources(sources: Array) -> EffectSet:
	var effect_set := EffectSet.new()
	for source in sources:
		if source:
			for effect: Effect in source.get_effects():
				effect_set.add(effect)
	return effect_set


func add(effect: Effect) -> void:
	if not _by_scope.has(effect.scope):
		_by_scope[effect.scope] = []
	_by_scope[effect.scope].append(effect)


func resolve(scope: Effect.Scope, base: Dictionary) -> Stats:
	return Stats.new(scope, base, _by_scope.get(scope, []))
