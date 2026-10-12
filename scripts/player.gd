class_name Player
extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -450.0
const FALL_LIMIT_Y := 1000.0
const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const PROJECTILE_SPAWN_OFFSET := 16.0
const STEP_HEIGHT := float(Map.CELL_SIZE)
const COYOTE_TIME := 0.1

@export var hotbar: Hotbar

@onready var spawn_position := position
@onready var health: Health = $Health
var fire_cooldown := 0.0
var coyote_timer := 0.0


func _ready() -> void:
	health.died.connect(respawn)


func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		velocity += get_gravity() * delta
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	velocity.x = Input.get_axis("move_left", "move_right") * SPEED

	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	var weapon := hotbar.selected_item as Weapon if hotbar else null
	if weapon and fire_cooldown == 0.0 and _is_trigger_pulled(weapon):
		_shoot(weapon)
		fire_cooldown = weapon.fire_interval

	_step_up_ledge(delta)
	move_and_slide()

	if position.y > FALL_LIMIT_Y:
		respawn()


func _step_up_ledge(delta: float) -> void:
	if not is_on_floor() or velocity.x == 0.0:
		return
	var motion := Vector2(velocity.x * delta, 0)
	var lift := Vector2(0, -STEP_HEIGHT)
	if not _hits_wall(global_transform, motion):
		return
	if test_move(global_transform, lift):
		return
	if _hits_wall(global_transform.translated(lift), motion):
		return
	global_position += lift


# Resting contact with the floor also counts as a collision, so only wall-facing normals block.
func _hits_wall(from: Transform2D, motion: Vector2) -> bool:
	var collision := KinematicCollision2D.new()
	return test_move(from, motion, collision) and absf(collision.get_normal().x) > 0.7


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
