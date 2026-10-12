extends Node2D

const SPAWN_HEIGHT := 32.0

## Leave at 0 to pick a random seed on every reset.
@export var fixed_seed := 0

@onready var map: Map = $Map
@onready var player: Player = $Player
@onready var chests: Chests = $Chests
@onready var info_label: Label = $UI/InfoLabel
var world_seed := 0


func _ready() -> void:
	regenerate()


func _physics_process(_delta: float) -> void:
	map.stream_around(player.global_position)


func _process(_delta: float) -> void:
	var position_px := Vector2i(player.global_position.round())
	var cell := map.local_to_map(map.to_local(player.global_position))
	info_label.text = "FPS: %d\nSeed: %d\nPosition: %d, %d\nTile: %d, %d" % [
		Engine.get_frames_per_second(), world_seed, position_px.x, position_px.y, cell.x, cell.y,
	]


func regenerate() -> void:
	world_seed = fixed_seed if fixed_seed != 0 else randi()
	chests.reset(world_seed)
	map.generate(world_seed)
	player.spawn_position = map.get_surface_position(0) - Vector2(0, SPAWN_HEIGHT)
	map.stream_around(player.spawn_position, true)
	player.respawn()
