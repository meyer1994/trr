class_name Map
extends TileMapLayer

const CELL_SIZE := 16
const SOURCE_ID := 0

const CHUNK_SIZE := 32
const LOAD_RADIUS := Vector2i(3, 2)
const UNLOAD_RADIUS := LOAD_RADIUS + Vector2i.ONE
const CHUNKS_PER_FRAME := 2

const SURFACE_AMPLITUDE_ROWS := 12.0
const SURFACE_FREQUENCY := 0.02
const CAVE_MIN_DEPTH := 8
const CAVE_FREQUENCY := 0.04
const CAVE_THRESHOLD := 0.3
const ISLAND_MIN_HEIGHT := 25
const ISLAND_FREQUENCY := 0.03
const ISLAND_SQUASH := 3.0
const ISLAND_THRESHOLD := 0.5
const STONE_DEPTH := 14
const STONE_WOBBLE_ROWS := 4.0

var _surface_noise := FastNoiseLite.new()
var _cave_noise := FastNoiseLite.new()
var _island_noise := FastNoiseLite.new()
var _loaded := {}
## Player changes that override the generator, kept while their chunk is unloaded.
## Maps a cell to its Block, or null for a removed block.
var _edits := {}
var _atlas_column := {}


func _ready() -> void:
	tile_set = _build_tile_set()


func generate(world_seed: int) -> void:
	_setup_noise(_surface_noise, world_seed, SURFACE_FREQUENCY, 3)
	_setup_noise(_cave_noise, world_seed + 1, CAVE_FREQUENCY, 2)
	_setup_noise(_island_noise, world_seed + 2, ISLAND_FREQUENCY, 2)
	clear()
	_loaded.clear()
	_edits.clear()


## Loads the chunks around a point and unloads the far ones.
## Loading is spread across frames unless `immediate` is set.
func stream_around(world_point: Vector2, immediate := false) -> void:
	var center := _chunk_at(world_point)
	for chunk: Vector2i in _loaded.keys():
		var offset := (chunk - center).abs()
		if offset.x > UNLOAD_RADIUS.x or offset.y > UNLOAD_RADIUS.y:
			_unload_chunk(chunk)

	var missing: Array[Vector2i] = []
	for x in range(-LOAD_RADIUS.x, LOAD_RADIUS.x + 1):
		for y in range(-LOAD_RADIUS.y, LOAD_RADIUS.y + 1):
			var chunk := center + Vector2i(x, y)
			if not _loaded.has(chunk):
				missing.append(chunk)
	if missing.is_empty():
		return
	missing.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return (a - center).length_squared() < (b - center).length_squared())
	var budget := missing.size() if immediate else CHUNKS_PER_FRAME
	for chunk in missing.slice(0, budget):
		_load_chunk(chunk)


func loaded_chunk_count() -> int:
	return _loaded.size()


func surface_row(column: int) -> int:
	return roundi(_surface_noise.get_noise_1d(column) * SURFACE_AMPLITUDE_ROWS)


## Generated block for a cell, ignoring player edits. Null means empty.
func generated_block_at(cell: Vector2i) -> Block:
	var surface := surface_row(cell.x)
	var solid := _is_solid(cell.x, cell.y, surface)
	var solid_above := _is_solid(cell.x, cell.y - 1, surface)
	return _pick_block(solid, solid_above, cell.y, surface, _stone_row(cell.x, surface))


## Block currently placed in a loaded cell. Null means empty.
func get_block(cell: Vector2i) -> Block:
	if get_cell_source_id(cell) == -1:
		return null
	return Blocks.ALL[get_cell_atlas_coords(cell).x]


## Places a block, or removes it when `block` is null. Survives chunk reloads.
func set_block(cell: Vector2i, block: Block) -> void:
	_place(cell, block)
	_edits[cell] = block


## Global position of the top edge of the surface cell in the column.
func get_surface_position(column: int) -> Vector2:
	var cell := Vector2i(column, surface_row(column))
	return to_global(map_to_local(cell) - Vector2(0, CELL_SIZE / 2.0))


func destroy_area(world_point: Vector2, radius: float) -> void:
	var center := local_to_map(to_local(world_point))
	set_block(center, null)
	var reach := ceili(radius / CELL_SIZE)
	for x in range(center.x - reach, center.x + reach + 1):
		for y in range(center.y - reach, center.y + reach + 1):
			var cell := Vector2i(x, y)
			if to_global(map_to_local(cell)).distance_to(world_point) <= radius:
				set_block(cell, null)


func _place(cell: Vector2i, block: Block) -> void:
	if block:
		set_cell(cell, SOURCE_ID, Vector2i(_atlas_column[block], 0))
	else:
		erase_cell(cell)


func _chunk_at(world_point: Vector2) -> Vector2i:
	var chunk_pixels := float(CHUNK_SIZE * CELL_SIZE)
	var local := to_local(world_point)
	return Vector2i(floori(local.x / chunk_pixels), floori(local.y / chunk_pixels))


func _load_chunk(chunk: Vector2i) -> void:
	var origin := chunk * CHUNK_SIZE
	for x in range(origin.x, origin.x + CHUNK_SIZE):
		var surface := surface_row(x)
		var stone_row := _stone_row(x, surface)
		var solid_above := _is_solid(x, origin.y - 1, surface)
		for y in range(origin.y, origin.y + CHUNK_SIZE):
			var cell := Vector2i(x, y)
			var solid := _is_solid(x, y, surface)
			var block: Block = _edits[cell] if _edits.has(cell) \
					else _pick_block(solid, solid_above, y, surface, stone_row)
			if block:
				_place(cell, block)
			solid_above = solid
	_loaded[chunk] = true


func _unload_chunk(chunk: Vector2i) -> void:
	var origin := chunk * CHUNK_SIZE
	for x in range(origin.x, origin.x + CHUNK_SIZE):
		for y in range(origin.y, origin.y + CHUNK_SIZE):
			erase_cell(Vector2i(x, y))
	_loaded.erase(chunk)


func _is_solid(x: int, y: int, surface: int) -> bool:
	if y >= surface:
		return y < surface + CAVE_MIN_DEPTH or _cave_noise.get_noise_2d(x, y) < CAVE_THRESHOLD
	if y <= surface - ISLAND_MIN_HEIGHT:
		return _island_noise.get_noise_2d(x, y * ISLAND_SQUASH) > ISLAND_THRESHOLD
	return false


func _stone_row(x: int, surface: int) -> int:
	return surface + STONE_DEPTH + roundi(_cave_noise.get_noise_1d(x) * STONE_WOBBLE_ROWS)


func _pick_block(solid: bool, solid_above: bool, y: int, surface: int, stone_row: int) -> Block:
	if not solid:
		return null
	if y <= surface and not solid_above:
		return Blocks.GRASS
	if y >= stone_row:
		return Blocks.STONE
	return Blocks.DIRT


func _setup_noise(noise: FastNoiseLite, noise_seed: int, frequency: float, octaves: int) -> void:
	noise.seed = noise_seed
	noise.frequency = frequency
	noise.fractal_octaves = octaves


func _build_tile_set() -> TileSet:
	var image := Image.create_empty(CELL_SIZE * Blocks.ALL.size(), CELL_SIZE, false, Image.FORMAT_RGBA8)
	for column in Blocks.ALL.size():
		var block := Blocks.ALL[column]
		block.paint(image, Vector2i(column * CELL_SIZE, 0), CELL_SIZE)
		_atlas_column[block] = column

	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(CELL_SIZE, CELL_SIZE)

	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(CELL_SIZE, CELL_SIZE)
	tiles.add_physics_layer()
	# The source must belong to the TileSet before its tiles can hold physics data.
	tiles.add_source(source, SOURCE_ID)

	var half := CELL_SIZE / 2.0
	var square := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half),
	])
	for column in Blocks.ALL.size():
		var tile := Vector2i(column, 0)
		source.create_tile(tile)
		var data := source.get_tile_data(tile, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, square)
	return tiles
