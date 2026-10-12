class_name Player
extends CharacterBody2D

signal stats_changed

const TARGET_SCOPE := Effect.Scope.PLAYER
const SPEED := 200.0
const JUMP_VELOCITY := -450.0
const MAX_FALL_SPEED := 1000.0
const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const PROJECTILE_SPAWN_OFFSET := 16.0
const STEP_HEIGHT := float(Map.CELL_SIZE)
const COYOTE_TIME := 0.1

@export var hotbar: Hotbar

@onready var spawn_position := position
@onready var health: Health = $Health
@onready var camera: Camera2D = $Camera2D
@onready var equipment: Equipment = $Equipment
var fire_cooldown := 0.0
var coyote_timer := 0.0
## Combined effects of worn equipment and the held item.
var effects := EffectSet.new()
var stats: Stats
## Stats of the held weapon, or null when not holding one.
var weapon_stats: Stats


func _ready() -> void:
	health.died.connect(respawn)
	equipment.changed.connect(_refresh_effects)
	if hotbar:
		hotbar.selection_changed.connect(_refresh_effects)
	_refresh_effects()


func base_stats() -> Dictionary:
	return {Effect.Stat.SPEED: SPEED, Effect.Stat.DEFENSE: 0.0}


func held_weapon() -> Weapon:
	return hotbar.selected_item as Weapon if hotbar else null


func _refresh_effects() -> void:
	var sources: Array = []
	sources.append_array(equipment.slots)
	if hotbar:
		sources.append(hotbar.selected_item)
	effects = EffectSet.from_sources(sources)
	stats = effects.resolve(TARGET_SCOPE, base_stats())
	var weapon := held_weapon()
	weapon_stats = effects.resolve(Weapon.TARGET_SCOPE, weapon.base_stats()) if weapon else null
	health.defense = roundi(stats.value(Effect.Stat.DEFENSE))
	stats_changed.emit()


func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		velocity += get_gravity() * delta
		velocity.y = minf(velocity.y, MAX_FALL_SPEED)
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	velocity.x = Input.get_axis("move_left", "move_right") * stats.value(Effect.Stat.SPEED)

	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	var weapon := held_weapon()
	if weapon and fire_cooldown == 0.0 and _is_trigger_pulled(weapon):
		_shoot(weapon)
		fire_cooldown = 1.0 / weapon_stats.value(Effect.Stat.FIRE_RATE)

	_step_up_ledge(delta)
	move_and_slide()


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
	camera.reset_smoothing()


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
	projectile.weapon = weapon
	projectile.direction = aim
	projectile.effects = effects
	projectile.position = position + aim * PROJECTILE_SPAWN_OFFSET
	get_parent().add_child(projectile)
