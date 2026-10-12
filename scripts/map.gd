class_name Map
extends TileMapLayer

const CELL_SIZE := 16
const SOURCE_ID := 0
const DIRT_TILE := Vector2i(0, 0)
const GRASS_TILE := Vector2i(1, 0)
const MAP_SIZE_CELLS := Vector2i(72, 41)
const SURFACE_BASE_ROW := 20
const SURFACE_AMPLITUDE_ROWS := 7.0
const SURFACE_FREQUENCY := 0.03
const DIRT_FILL_COLOR := Color(0.42, 0.33, 0.25)
const DIRT_EDGE_COLOR := Color(0.32, 0.25, 0.19)
const GRASS_FILL_COLOR := Color(0.36, 0.62, 0.26)
const GRASS_DEPTH := 5


func _ready() -> void:
	tile_set = _build_tile_set()


func generate(world_seed: int) -> void:
	clear()
	var noise := FastNoiseLite.new()
	noise.seed = world_seed
	noise.frequency = SURFACE_FREQUENCY
	noise.fractal_octaves = 3

	for x in MAP_SIZE_CELLS.x:
		var surface_row := SURFACE_BASE_ROW + roundi(noise.get_noise_1d(x) * SURFACE_AMPLITUDE_ROWS)
		set_cell(Vector2i(x, surface_row), SOURCE_ID, GRASS_TILE)
		for y in range(surface_row + 1, MAP_SIZE_CELLS.y):
			set_cell(Vector2i(x, y), SOURCE_ID, DIRT_TILE)


## Global position of the top edge of the highest solid cell in the column.
func get_surface_position(column: int) -> Vector2:
	var row := 0
	while row < MAP_SIZE_CELLS.y and get_cell_source_id(Vector2i(column, row)) == -1:
		row += 1
	return to_global(map_to_local(Vector2i(column, row)) - Vector2(0, CELL_SIZE / 2.0))


func destroy_area(world_point: Vector2, radius: float) -> void:
	var center := local_to_map(to_local(world_point))
	erase_cell(center)
	var reach := ceili(radius / CELL_SIZE)
	for x in range(center.x - reach, center.x + reach + 1):
		for y in range(center.y - reach, center.y + reach + 1):
			var cell := Vector2i(x, y)
			if to_global(map_to_local(cell)).distance_to(world_point) <= radius:
				erase_cell(cell)


func _build_tile_set() -> TileSet:
	var image := Image.create_empty(CELL_SIZE * 2, CELL_SIZE, false, Image.FORMAT_RGBA8)
	_paint_tile(image, DIRT_TILE)
	_paint_tile(image, GRASS_TILE)
	var grass_origin := GRASS_TILE * CELL_SIZE + Vector2i.ONE
	image.fill_rect(Rect2i(grass_origin, Vector2i(CELL_SIZE - 1, GRASS_DEPTH)), GRASS_FILL_COLOR)

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
	for tile in [DIRT_TILE, GRASS_TILE]:
		source.create_tile(tile)
		var data := source.get_tile_data(tile, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, square)
	return tiles


func _paint_tile(image: Image, tile: Vector2i) -> void:
	var origin := tile * CELL_SIZE
	image.fill_rect(Rect2i(origin, Vector2i(CELL_SIZE, CELL_SIZE)), DIRT_EDGE_COLOR)
	image.fill_rect(Rect2i(origin + Vector2i.ONE, Vector2i(CELL_SIZE - 1, CELL_SIZE - 1)), DIRT_FILL_COLOR)
