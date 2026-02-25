extends Node

enum AreaShape {
	Circle,
	Square,
	Line
}

enum Direction {
	Right,
	Down,
	Left,
	Up
}

enum UnitType {
	Enemy,
	Hero,
	Any
}

@onready var tilemap: TileMapLayer : set = _set_tilemap

var grid: AStarGrid2D
var TILE_SIZE: Vector2


func init_level(level_tilemap: TileMapLayer) -> void:
	tilemap = level_tilemap
	
	#Setup a star grid
	grid = AStarGrid2D.new()
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.region = tilemap.get_used_rect()
	grid.cell_size = TILE_SIZE
	grid.update()
	
	remove_unwalkable_tiles_from_grid()
	remove_unit_tiles_from_grid()

func remove_unwalkable_tiles_from_grid() -> void:
	var start_pos = grid.region.position
	var end_pos = start_pos + grid.region.size
	for x in range(start_pos.x, end_pos.x):
		for y in range(start_pos.y, end_pos.y):
			var tile = Vector2i(x,y)
			var data = tilemap.get_cell_tile_data(tile)
			if data and data.get_custom_data("is_walkable"):
				pass
			else:
				grid.set_point_solid(tile)


func remove_unit_tiles_from_grid() -> void:
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		var unit_pos = get_tile_coords(unit.global_position)
		grid.set_point_solid(unit_pos)


func set_point_solid(point: Vector2i) -> void:
	grid.set_point_solid(point)


func set_point_walkable(point: Vector2i) -> void:
	grid.set_point_solid(point, false)


func snap_to_grid(coords: Vector2) -> Vector2:
	var half_tile = Vector2(0.5,0.5)
	var tile_coords = Vector2(get_tile_coords(coords))
	return (tile_coords+half_tile) * 64


func get_tile_coords(coords: Vector2) -> Vector2i:
	return tilemap.local_to_map(coords)


func get_world_coords(tile_coords: Vector2i) -> Vector2:
	return tilemap.map_to_local(tile_coords)


func _set_tilemap(value: TileMapLayer) -> void:
	tilemap = value
	TILE_SIZE = tilemap.tile_set.tile_size


func get_cell_path(start_pos: Vector2i, end_pos: Vector2i) -> Array[Vector2i]:
	return grid.get_id_path(start_pos,end_pos)


func get_move_area(start_pos: Vector2i, move_speed: int) -> Array[Vector2i]:
	var tiles = get_shape_tiles(AreaShape.Square,move_speed,start_pos)
	var moveable_tiles: Array[Vector2i] = []
	
	for tile in tiles:
		if is_tile_in_bounds(tile):
			var path = grid.get_id_path(tile, start_pos)
			if len(path) <= move_speed + 1 and len(path) != 0:
				moveable_tiles.append(tile)
			
	return moveable_tiles


func get_unit_at_tile(tile: Vector2i) -> Unit:
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if get_tile_coords(unit.global_position) == tile:
			return unit
	return null


func get_units(type: UnitType) -> Array[Node]:
	var units: Array[Node]
	match type:
		UnitType.Enemy:
			units = get_tree().get_nodes_in_group("enemies")
		UnitType.Hero:
			units = get_tree().get_nodes_in_group("heroes")
		UnitType.Any:
			units = get_tree().get_nodes_in_group("units")
	return units


func get_nearest(position: Vector2i, type: UnitType) -> Array[Unit]:
	var nearest: Array[Unit]
	var units: Array[Node]
	match type:
		UnitType.Enemy:
			units = get_tree().get_nodes_in_group("enemies")
		UnitType.Hero:
			units = get_tree().get_nodes_in_group("heroes")
		UnitType.Any:
			units = get_tree().get_nodes_in_group("units")
	
	for unit in units:
		if nearest.size() == 0:
			nearest = [unit]
		else:
			var unit_position = get_tile_coords(unit.global_position)
			var nearest_position = get_tile_coords(nearest[0].global_position)
			var distance_to_unit = max(abs(position.x-unit_position.x),abs(position.y-unit_position.y))
			var distance_to_nearest = max(abs(position.x-nearest_position.x),abs(position.y-nearest_position.y))

			if distance_to_unit < distance_to_nearest:
				nearest = [unit]
			elif distance_to_unit == distance_to_nearest:
				nearest.append(unit)
				
	return nearest


func find_closest_tiles(position: Vector2i, tiles: Array[Vector2i]) -> Array[Vector2i]:
	var nearest: Array[Vector2i] = []
	for tile in tiles:
		var distance_to_nearest = 999
		var path = grid.get_id_path(position,tile)
		var distance_to_tile = len(path)
		if nearest.size() > 0:
			distance_to_nearest = len(grid.get_id_path(position,nearest[0]))
		
		if distance_to_tile < distance_to_nearest and distance_to_tile != 0:
			nearest = [tile]
		elif distance_to_tile == distance_to_nearest and distance_to_tile != 0:
			nearest.append(tile)
				
	return nearest



func is_tile_in_bounds(tile: Vector2i) -> bool:
	var start = grid.region.position
	var end = grid.region.size + start - Vector2i.ONE
	
	if tile.x < start.x or tile.x > end.x or tile.y < start.y or tile.y > end.y:
		return false
		
	return true


func get_all_tiles() -> Array[Vector2i]:
	return tilemap.get_used_cells()


##Returns an array containing the coordinates of all tiles in the defined area
func get_shape_tiles(shape:AreaShape, radius: int, origin: Vector2i = Vector2i(0,0), include_target: bool = false, direction: Direction = Direction.Right) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var size = (radius * 2) + 1
	
	match shape:
		AreaShape.Line:
			for x in range(radius):
				var tile = Vector2(x+1,0).rotated(direction * PI/2)
				tiles.append(Vector2i(tile)+origin)
				
		AreaShape.Square:
			for x in range(size):
				for y in range(size):
					tiles.append(Vector2i(x-radius,y-radius)+origin)
					
		AreaShape.Circle:
			for x in range(size):
				for y in range(size):
					var x_pos = x-radius
					var y_pos = y-radius
					if x_pos*x_pos + y_pos*y_pos <= (radius+0.5)*(radius+0.5):
						tiles.append(Vector2i(x-radius,y-radius)+origin)
	
	if not include_target:
		tiles.erase(origin)
	
	return tiles
