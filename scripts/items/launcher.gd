class_name Launcher
extends Weapon


func _init() -> void:
	automatic = false
	fire_interval = 0.8
	projectile_size = Vector2(10, 10)
	projectile_speed = 550.0
	projectile_gravity = 600.0
	blast_radius = 48.0
	icon_size = Vector2(28, 12)
