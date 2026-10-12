extends TileMapLayer

const CELL_SIZE := 8
const SOURCE_ID := 0
const TILE := Vector2i.ZERO
const MAP_SIZE_CELLS := Vector2i(144, 81)
const GROUND_TOP_ROW := 40
const FILL_COLOR := Color(0.42, 0.33, 0.25)
const EDGE_COLOR := Color(0.32, 0.25, 0.19)

@export var player: Node2D
@export var hole_size_cells := Vector2i(12, 8)


func _ready() -> void:
	tile_set = _build_tile_set()
	_fill_ground()
	_carve_hole_around_player()


func destroy_area(world_point: Vector2, radius: float) -> void:
	var center := local_to_map(to_local(world_point))
	var reach := ceili(radius / CELL_SIZE)
	for x in range(center.x - reach, center.x + reach + 1):
		for y in range(center.y - reach, center.y + reach + 1):
			var cell := Vector2i(x, y)
			if to_global(map_to_local(cell)).distance_to(world_point) <= radius:
				erase_cell(cell)


func _build_tile_set() -> TileSet:
	var image := Image.create_empty(CELL_SIZE, CELL_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(EDGE_COLOR)
	image.fill_rect(Rect2i(1, 1, CELL_SIZE - 1, CELL_SIZE - 1), FILL_COLOR)

	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(CELL_SIZE, CELL_SIZE)

	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(CELL_SIZE, CELL_SIZE)
	tiles.add_physics_layer()
	# The source must belong to the TileSet before its tiles can hold physics data.
	tiles.add_source(source, SOURCE_ID)
	source.create_tile(TILE)

	var half := CELL_SIZE / 2.0
	var data := source.get_tile_data(TILE, 0)
	data.add_collision_polygon(0)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half),
	]))
	return tiles


func _fill_ground() -> void:
	for x in MAP_SIZE_CELLS.x:
		for y in range(GROUND_TOP_ROW, MAP_SIZE_CELLS.y):
			set_cell(Vector2i(x, y), SOURCE_ID, TILE)


func _carve_hole_around_player() -> void:
	if player == null:
		return
	var top_left := local_to_map(to_local(player.global_position)) - hole_size_cells / 2
	for x in hole_size_cells.x:
		for y in hole_size_cells.y:
			erase_cell(top_left + Vector2i(x, y))
