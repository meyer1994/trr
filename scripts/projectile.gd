extends Node2D

const LIFETIME := 2.0
const WORLD_COLLISION_MASK := 1

var weapon: Weapon
var velocity := Vector2.ZERO
var damage := 0.0
var splash_radius := 0.0

@onready var body: ColorRect = $ColorRect


func _ready() -> void:
	rotation = velocity.angle()
	body.color = weapon.projectile_color
	body.size = weapon.projectile_size
	body.position = -weapon.projectile_size / 2
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	velocity.y += weapon.projectile_gravity * delta
	rotation = velocity.angle()

	# Ray-cast each step so fast shots can't skip over thin walls between frames.
	var next_position := global_position + velocity * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next_position, WORLD_COLLISION_MASK)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		global_position = next_position
		return

	if hit.collider.has_method("damage_area"):
		hit.collider.damage_area(hit.position - hit.normal, splash_radius, damage)
	queue_free()
