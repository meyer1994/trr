class_name Pistol
extends Weapon


func _init() -> void:
	automatic = false
	fire_interval = 0.25
	projectile_size = Vector2(10, 5)
	projectile_speed = 750.0
	blast_radius = 10.0
	icon_size = Vector2(16, 10)
