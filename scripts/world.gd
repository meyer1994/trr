extends Node2D

const SPAWN_HEIGHT := 32.0

@onready var map: Map = $Map
@onready var player: Player = $Player


func _ready() -> void:
	regenerate()


func regenerate() -> void:
	map.generate(randi())
	var spawn_column := Map.MAP_SIZE_CELLS.x / 2
	player.spawn_position = map.get_surface_position(spawn_column) - Vector2(0, SPAWN_HEIGHT)
	player.respawn()
