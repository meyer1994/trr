extends Node2D

const SPAWN_HEIGHT := 32.0

## Leave at 0 to pick a random seed on every reset.
@export var fixed_seed := 0

@onready var map: Map = $Map
@onready var player: Player = $Player
@onready var seed_label: Label = $UI/SeedLabel
var world_seed := 0


func _ready() -> void:
	regenerate()


func _physics_process(_delta: float) -> void:
	map.stream_around(player.global_position)


func regenerate() -> void:
	world_seed = fixed_seed if fixed_seed != 0 else randi()
	seed_label.text = "Seed: %d" % world_seed
	map.generate(world_seed)
	player.spawn_position = map.get_surface_position(0) - Vector2(0, SPAWN_HEIGHT)
	map.stream_around(player.spawn_position, true)
	player.respawn()
