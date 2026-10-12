class_name Chests
extends Node2D

## Places chests as chunks load, remembers what's left in opened ones, and opens them on right-click.

signal opened(chest: Chest)
signal closed

## Chance that a chunk has a chest, if it has a free spot on solid ground.
const CHANCE_PER_CHUNK := 0.3
## Random columns tried per chunk when looking for that spot.
const ATTEMPTS := 6
const SLOT_COUNT := 20
## How far from the player, in pixels, a chest can be opened.
const REACH := 80.0

@export var map: Map
@export var player: Player
@export var surface_loot: LootTable
@export var cave_loot: LootTable
@export var island_loot: LootTable

## The chest whose contents are shown, or null.
var open_chest: Chest
var world_seed := 0
## Loaded chests by chunk and by cell.
var _by_chunk := {}
var _by_cell := {}
## Contents of every chest opened so far, by cell. Kept while the chest's chunk is unloaded.
var _contents := {}


func _ready() -> void:
	map.chunk_loaded.connect(_on_chunk_loaded)
	map.chunk_unloaded.connect(_on_chunk_unloaded)


## Forgets every chest. Call before the map generates a new world.
func reset(new_seed: int) -> void:
	close()
	world_seed = new_seed
	for chest: Chest in _by_cell.values():
		map.protected_cells.erase(chest.cell + Vector2i.DOWN)
		chest.queue_free()
	_by_chunk.clear()
	_by_cell.clear()
	_contents.clear()


func chest_at(world_point: Vector2) -> Chest:
	return _by_cell.get(map.local_to_map(map.to_local(world_point)))


## The chest's items, rolled from its loot table the first time they're needed.
func contents(chest: Chest) -> ItemContainer:
	if not _contents.has(chest.cell):
		var container := ItemContainer.new(SLOT_COUNT)
		var rng := RandomNumberGenerator.new()
		rng.seed = hash([world_seed, chest.cell, "loot"])
		for stack in _loot_table(chest.band).roll(rng):
			container.add(stack)
		_contents[chest.cell] = container
	return _contents[chest.cell]


func open(chest: Chest) -> void:
	close()
	open_chest = chest
	chest.is_open = true
	opened.emit(chest)


func close() -> void:
	if not open_chest:
		return
	open_chest.is_open = false
	open_chest = null
	closed.emit()


## Moves an inventory stack into the open chest.
func store(inventory_index: int) -> void:
	if open_chest:
		player.inventory.move_to(inventory_index, contents(open_chest))


## Moves a stack from the open chest into the inventory.
func retrieve(chest_index: int) -> void:
	if open_chest:
		contents(open_chest).move_to(chest_index, player.inventory)


## Opens or closes the chest at a point if it's within reach. Returns false when there's none.
func interact_at(world_point: Vector2) -> bool:
	var chest := chest_at(world_point)
	if not chest or not _in_reach(chest):
		return false
	if chest == open_chest:
		close()
	else:
		open(chest)
	return true


# This node comes after the player in the tree, so it sees right-clicks before the player wears anything.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("wear") and interact_at(get_global_mouse_position()):
		get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	if open_chest and not _in_reach(open_chest):
		close()


func _in_reach(chest: Chest) -> bool:
	return player.global_position.distance_to(chest.global_position) <= REACH


func _on_chunk_loaded(chunk: Vector2i) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([world_seed, chunk])
	if rng.randf() >= CHANCE_PER_CHUNK:
		return
	var origin := chunk * Map.CHUNK_SIZE
	for attempt in ATTEMPTS:
		var column := origin.x + rng.randi_range(0, Map.CHUNK_SIZE - 1)
		var cell: Variant = _find_floor(column, origin.y + rng.randi_range(0, Map.CHUNK_SIZE - 2), origin.y + Map.CHUNK_SIZE - 1)
		if cell != null:
			_spawn(chunk, cell)
			return


## First empty generated cell at or below `top` with solid ground under it, staying above `bottom`.
func _find_floor(column: int, top: int, bottom: int) -> Variant:
	for y in range(top, bottom):
		var cell := Vector2i(column, y)
		if not map.generated_block_at(cell) and map.generated_block_at(cell + Vector2i.DOWN):
			return cell
	return null


func _spawn(chunk: Vector2i, cell: Vector2i) -> void:
	var chest := Chest.new(cell, _band_at(cell))
	var floor_point := map.map_to_local(cell) + Vector2(0, Map.CELL_SIZE / 2.0)
	chest.position = to_local(map.to_global(floor_point))
	add_child(chest)
	_by_chunk[chunk] = chest
	_by_cell[cell] = chest
	map.protected_cells[cell + Vector2i.DOWN] = true


func _on_chunk_unloaded(chunk: Vector2i) -> void:
	var chest: Chest = _by_chunk.get(chunk)
	if not chest:
		return
	if chest == open_chest:
		close()
	_by_chunk.erase(chunk)
	_by_cell.erase(chest.cell)
	map.protected_cells.erase(chest.cell + Vector2i.DOWN)
	chest.queue_free()


func _band_at(cell: Vector2i) -> Chest.Band:
	var surface := map.surface_row(cell.x)
	if cell.y <= surface - Map.ISLAND_MIN_HEIGHT:
		return Chest.Band.ISLAND
	if cell.y < surface:
		return Chest.Band.SURFACE
	return Chest.Band.CAVE


func _loot_table(band: Chest.Band) -> LootTable:
	match band:
		Chest.Band.CAVE:
			return cave_loot
		Chest.Band.ISLAND:
			return island_loot
	return surface_loot
