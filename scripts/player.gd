class_name Player
extends CharacterBody2D

signal stats_changed
signal held_changed

const SPEED := 200.0
const JUMP_VELOCITY := -450.0
const MAX_FALL_SPEED := 1000.0
const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const PROJECTILE_SPAWN_OFFSET := 16.0
const STEP_HEIGHT := float(Map.CELL_SIZE)
const COYOTE_TIME := 0.1
const HOTBAR_KEYS: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]

@onready var spawn_position := position
@onready var health: Health = $Health
@onready var camera: Camera2D = $Camera2D
@onready var inventory: Inventory = $Inventory
@onready var equipment: Equipment = $Equipment
var fire_cooldown := 0.0
var coyote_timer := 0.0
## Inventory slot of the held item; always within the hotbar.
var held_index := 0
## Combined effects of worn equipment and the held item.
var effects := EffectSet.new()
var stats: Stats
## Stats of the held weapon, which its shots inherit. Null when not holding a weapon.
var held_stats: Stats


func _ready() -> void:
	health.died.connect(respawn)
	inventory.changed.connect(_refresh_effects)
	equipment.changed.connect(_refresh_effects)
	_refresh_effects()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var index := HOTBAR_KEYS.find(event.physical_keycode)
		if index != -1:
			hold(index)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("wear"):
		wear(held_index)
		get_viewport().set_input_as_handled()


func held_stack() -> ItemStack:
	return inventory.slots[held_index]


func held_weapon() -> Weapon:
	var stack := held_stack()
	return stack.item as Weapon if stack else null


func hold(index: int) -> void:
	held_index = index
	held_changed.emit()
	_refresh_effects()


## Moves a wearable stack from the inventory into equipment; the piece it replaces takes its slot.
func wear(inventory_index: int) -> void:
	var stack := inventory.slots[inventory_index]
	if not stack or not stack.item is Equippable:
		return
	inventory.take(inventory_index)
	var replaced := equipment.equip(stack)
	if replaced:
		inventory.put(inventory_index, replaced)


## Moves a worn piece into the first free inventory slot. Does nothing when the inventory is full.
func take_off(slot_index: int) -> void:
	var stack := equipment.slots[slot_index]
	if not stack or not inventory.add(stack):
		return
	equipment.unequip(slot_index)


func _refresh_effects() -> void:
	var sources: Array = []
	sources.append_array(equipment.slots)
	var held := held_stack()
	if held and not held.item is Equippable:
		sources.append(held)
	effects = EffectSet.from_sources(sources)

	var defense := 0.0
	for stack in equipment.slots:
		if stack:
			defense += effects.resolve(Effect.Target.WORN, stack.item.base_stats()).value(Effect.Stat.DEFENSE)
	stats = effects.resolve(Effect.Target.PLAYER, {Effect.Stat.SPEED: SPEED, Effect.Stat.DEFENSE: defense})

	var weapon := held_weapon()
	held_stats = effects.resolve(Effect.Target.HELD, weapon.base_stats()) if weapon else null
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
		fire_cooldown = 1.0 / held_stats.value(Effect.Stat.FIRE_RATE)

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
	projectile.stats = held_stats
	projectile.position = position + aim * PROJECTILE_SPAWN_OFFSET
	get_parent().add_child(projectile)
