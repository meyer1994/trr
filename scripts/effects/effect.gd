class_name Effect
extends Resource

## What the effect changes: the player, every worn piece, or the held item and its shots.
enum Target { PLAYER, WORN, HELD }
enum Stat { SPEED, DEFENSE, FIRE_RATE, DAMAGE, SPLASH_RADIUS, GRAVITY }
enum Mode { FLAT, PERCENT }

## Stats each target can have. SPEED is walking speed on PLAYER and projectile speed on HELD.
const TARGET_STATS := {
	Target.PLAYER: [Stat.SPEED, Stat.DEFENSE],
	Target.WORN: [Stat.DEFENSE],
	Target.HELD: [Stat.FIRE_RATE, Stat.SPEED, Stat.DAMAGE, Stat.SPLASH_RADIUS, Stat.GRAVITY],
}

@export var target := Target.PLAYER
@export var stat := Stat.DAMAGE
@export var mode := Mode.PERCENT
## FLAT adds this amount to the base; PERCENT adds this fraction of it, e.g. 0.25 for +25%.
@export var value := 0.0


func is_valid() -> bool:
	return stat in TARGET_STATS[target]
