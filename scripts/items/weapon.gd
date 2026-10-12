class_name Weapon
extends Item

const TARGET_SCOPE := Effect.Scope.WEAPON

@export var automatic := false
@export var fire_interval := 0.25
@export var damage := 10.0
## Every block within this many pixels of the hit also takes the damage.
@export var splash_radius := 0.0
@export var projectile_color := Color.WHITE
@export var projectile_size := Vector2(12, 6)
@export var projectile_speed := 700.0
@export var projectile_gravity := 0.0


func base_stats() -> Dictionary:
	return {Effect.Stat.FIRE_RATE: 1.0 / fire_interval}
