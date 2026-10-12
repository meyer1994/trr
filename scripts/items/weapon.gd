class_name Weapon
extends Item

@export var automatic := false
@export var fire_interval := 0.25
@export var damage := 10.0
## Every block within this many pixels of the hit also takes the damage.
@export var splash_radius := 0.0
@export var projectile_color := Color.WHITE
@export var projectile_size := Vector2(12, 6)
@export var projectile_speed := 700.0
@export var projectile_gravity := 0.0
## Fraction of its velocity a shot loses to the air each second. As it slows, gravity takes over
## and the path bends from a gentle arc into a near-vertical fall.
@export var projectile_drag := 0.0


## Held stats, including the ones each projectile it fires inherits.
func base_stats() -> Dictionary:
	return {
		Effect.Stat.FIRE_RATE: 1.0 / fire_interval,
		Effect.Stat.SPEED: projectile_speed,
		Effect.Stat.DAMAGE: damage,
		Effect.Stat.SPLASH_RADIUS: splash_radius,
		Effect.Stat.GRAVITY: projectile_gravity,
	}
