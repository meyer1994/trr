extends Node2D

const SPEED := 700.0
const LIFETIME := 2.0
const BLAST_RADIUS := 10.0
const WORLD_COLLISION_MASK := 1

var direction := Vector2.RIGHT


func _ready() -> void:
	rotation = direction.angle()
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	# Ray-cast each step so fast shots can't skip over thin walls between frames.
	var next_position := global_position + direction * SPEED * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next_position, WORLD_COLLISION_MASK)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		global_position = next_position
		return

	if hit.collider.has_method("destroy_area"):
		hit.collider.destroy_area(hit.position, BLAST_RADIUS)
	queue_free()
