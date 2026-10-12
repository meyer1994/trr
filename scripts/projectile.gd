extends Node2D

const LIFETIME := 2.0
const WORLD_COLLISION_MASK := 1

var direction := Vector2.RIGHT
var tool: Tool

@onready var body: ColorRect = $ColorRect


func _ready() -> void:
	rotation = direction.angle()
	body.color = tool.color
	body.size = tool.projectile_size
	body.position = -tool.projectile_size / 2
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	# Ray-cast each step so fast shots can't skip over thin walls between frames.
	var next_position := global_position + direction * tool.speed * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next_position, WORLD_COLLISION_MASK)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		global_position = next_position
		return

	if hit.collider.has_method("destroy_area"):
		hit.collider.destroy_area(hit.position, tool.blast_radius)
	queue_free()
