class_name Effect
extends Resource

## What the effect changes: the player, the held weapon, or each projectile it fires.
enum Scope { PLAYER, WEAPON, PROJECTILE }
enum Stat { SPEED, DEFENSE, FIRE_RATE, DAMAGE, SPLASH_RADIUS, GRAVITY }
enum Mode { FLAT, PERCENT }

@export var scope := Scope.PLAYER
@export var stat := Stat.DAMAGE
@export var mode := Mode.PERCENT
## FLAT adds this amount to the base; PERCENT adds this fraction of it, e.g. 0.25 for +25%.
@export var value := 0.0
