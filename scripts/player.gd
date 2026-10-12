class_name Player
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -550.0
const FALL_LIMIT_Y := 1000.0
const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const PROJECTILE_SPAWN_OFFSET := 12.0

@export var hotbar: Hotbar

@onready var spawn_position := position
@onready var health: Health = $Health
var fire_cooldown := 0.0


func _ready() -> void:
	health.died.connect(respawn)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity.x = Input.get_axis("move_left", "move_right") * SPEED

	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	var weapon := hotbar.selected_item as Weapon if hotbar else null
	if weapon and fire_cooldown == 0.0 and _is_trigger_pulled(weapon):
		_shoot(weapon)
		fire_cooldown = weapon.fire_interval

	move_and_slide()

	if position.y > FALL_LIMIT_Y:
		respawn()


func respawn() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	health.reset()


func _is_trigger_pulled(weapon: Weapon) -> bool:
	if get_viewport().gui_get_hovered_control() != null:
		return false
	if weapon.automatic:
		return Input.is_action_pressed("shoot")
	return Input.is_action_just_pressed("shoot")


func _shoot(weapon: Weapon) -> void:
	var aim := global_position.direction_to(get_global_mouse_position())
	if aim == Vector2.ZERO:
		aim = Vector2.RIGHT

	var projectile := PROJECTILE_SCENE.instantiate()
	projectile.direction = aim
	projectile.weapon = weapon
	projectile.position = position + aim * PROJECTILE_SPAWN_OFFSET
	get_parent().add_child(projectile)
