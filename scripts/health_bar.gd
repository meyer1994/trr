extends Node2D

const SIZE := Vector2(16, 3)
const BACKGROUND_COLOR := Color(0, 0, 0, 0.6)
const FILL_COLOR := Color(0.3, 0.9, 0.3)

@export var health: Health


func _ready() -> void:
	health.changed.connect(queue_redraw.unbind(2))


func _draw() -> void:
	var origin := -SIZE / 2
	var ratio := float(health.current) / health.max_health
	draw_rect(Rect2(origin, SIZE), BACKGROUND_COLOR)
	draw_rect(Rect2(origin, Vector2(SIZE.x * ratio, SIZE.y)), FILL_COLOR)
