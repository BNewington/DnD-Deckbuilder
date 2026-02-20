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
	
	#Remove unwalkable tiles from grid
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


func get_move_area(start_pos: Vector2i, move_speed: int) -> Array[Vector2i]:
	var tiles = get_shape_tiles(AreaShape.Square,move_speed,start_pos)
	var moveable_tiles: Array[Vector2i] = []
	
	for tile in tiles:
		if is_tile_in_bounds(tile):
			var path = grid.get_id_path(tile, start_pos)
			if len(path) <= move_speed + 1 and len(path) != 0:
				moveable_tiles.append(tile)
			
	return moveable_tiles


func is_tile_in_bounds(tile: Vector2i) -> bool:
	var start = grid.region.position
	var end = grid.region.size + start - Vector2i.ONE
	
	if tile.x < start.x or tile.x > end.x or tile.y < start.y or tile.y > end.y:
		return false
		
	return true


##Returns an array containing the coordinates of all tiles in the defined area
func get_shape_tiles(shape:AreaShape, radius: int, origin: Vector2i = Vector2i(0,0), direction: Direction = Direction.Right) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var size = (radius * 2) + 1
	
	match shape:
		AreaShape.Line:
			for x in range(radius):
				var tile = Vector2(x+1,0).rotated(direction * PI/2)
				tiles.append(Vector2i(tile+origin))
				
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
	
	return tiles
