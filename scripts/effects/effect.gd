class_name Effect
extends Resource

enum Stat { MOVE_SPEED, DEFENSE, FIRE_RATE, DAMAGE, SPLASH_RADIUS, PROJECTILE_SPEED }
enum Mode { FLAT, PERCENT }

@export var stat := Stat.DAMAGE
@export var mode := Mode.PERCENT
## FLAT adds this amount to the base; PERCENT adds this fraction of it, e.g. 0.25 for +25%.
@export var value := 0.0
