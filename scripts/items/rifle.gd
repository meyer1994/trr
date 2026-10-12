class_name Rifle
extends Weapon


func _init() -> void:
	automatic = true
	fire_interval = 0.08
	projectile_size = Vector2(10, 3)
	projectile_speed = 1100.0
	blast_radius = 0.0
	icon_size = Vector2(30, 6)
