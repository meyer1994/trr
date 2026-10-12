extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -550.0
const FALL_LIMIT_Y := 1000.0
const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const PROJECTILE_SPAWN_OFFSET := 12.0

@onready var spawn_position := position


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity.x = Input.get_axis("move_left", "move_right") * SPEED

	if Input.is_action_just_pressed("shoot"):
		_shoot()

	move_and_slide()

	if position.y > FALL_LIMIT_Y:
		position = spawn_position
		velocity = Vector2.ZERO


func _shoot() -> void:
	var aim := global_position.direction_to(get_global_mouse_position())
	if aim == Vector2.ZERO:
		aim = Vector2.RIGHT

	var projectile := PROJECTILE_SCENE.instantiate()
	projectile.direction = aim
	projectile.position = position + aim * PROJECTILE_SPAWN_OFFSET
	get_parent().add_child(projectile)
