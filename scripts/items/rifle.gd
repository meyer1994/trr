class_name Rifle
extends Weapon


func _init() -> void:
	automatic = true
	fire_interval = 0.08
	damage = 4.0
	splash_radius = 0.0
	projectile_size = Vector2(10, 3)
	projectile_speed = 1100.0
	projectile_gravity = 100.0
	projectile_drag = 0.3
	icon_size = Vector2(30, 6)
