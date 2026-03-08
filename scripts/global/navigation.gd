extends Node3D

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

var MODE_3D = true
var stretch_shrink = 2

@onready var tilemap: TileMapLayer : set = _set_tilemap

var gridmap: GridMap : set = _set_gridmap
var camera: Camera3D
var grid: AStarGrid2D
var TILE_SIZE: Vector2

var floor_height: float = 1.1

func init(level_gridmap: GridMap, level_camera: Camera3D) -> void:
	camera = level_camera
	gridmap = level_gridmap
	grid = AStarGrid2D.new()
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.region = find_used_rect(gridmap)
	grid.cell_size = TILE_SIZE
	grid.update()
	
	remove_unit_tiles_from_grid()
	remove_empty_tiles_from_grid()


func find_used_rect(map: GridMap) -> Rect2i:
	var cells = []
	for cell in map.get_used_cells():
		cells.append(flatten(cell))
	
	var min_x: int = 999
	var min_y: int = 999
	var max_x: int = -999
	var max_y: int = -999
	for cell in cells:
		if cell.x < min_x:
			min_x = cell.x
		elif cell.x > max_x:
			max_x = cell.x
		
		if cell.y < min_y:
			min_y = cell.y
		elif cell.y > max_y:
			max_y = cell.y
	
	var top_left = Vector2i(min_x,min_y)
	var bottom_right = Vector2i(max_x+1,max_y+1)
	var rect: Rect2i
	rect.position = top_left
	rect.end = bottom_right
	return rect


func find_3d_mouse_pos() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()/stretch_shrink
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000
	var query = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	var ray = space_state.intersect_ray(query)
	if ray.has("position"):
		return ray["position"]
	return Vector3()


func find_2d_screen_pos(pos: Vector3) -> Vector2:
	return camera.unproject_position(pos) * stretch_shrink


func flatten(vector: Vector3i) -> Vector2i:
	return Vector2i(vector.x, vector.z)


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


func remove_empty_tiles_from_grid() -> void:
	var used_cells = gridmap.get_used_cells()
	var used_cells_2d: Array[Vector2i]
	for cell in used_cells:
		used_cells_2d.append(flatten(cell))
	
	var start_pos = grid.region.position
	var end_pos = start_pos + grid.region.size
	for x in range(start_pos.x, end_pos.x):
		for y in range(start_pos.y, end_pos.y):
			var tile = Vector2i(x,y)
			if not tile in used_cells_2d:
				grid.set_point_solid(tile)


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


func set_units_solid(type: UnitType, is_solid: bool = true) -> void:
	var units: Array[Node] = get_units(type)
	for unit in units:
		var unit_pos = get_tile_coords(unit.global_position)
		grid.set_point_solid(unit_pos,is_solid)


func set_point_solid(point: Vector2i) -> void:
	grid.set_point_solid(point)


func set_point_walkable(point: Vector2i) -> void:
	grid.set_point_solid(point, false)


func is_point_solid(point: Vector2i) -> bool:
	return grid.is_point_solid(point)


func snap_to_grid(coords: Vector3) -> Vector3:
	var tile_coords = get_tile_coords(coords)
	var world_coords = get_world_coords(tile_coords)
	var floor_coords = Vector3(world_coords.x,floor_height,world_coords.z)
	return floor_coords


func get_tile_coords(coords: Vector3) -> Vector2i:
	var coords_3d = gridmap.local_to_map(coords)
	if coords_3d == Vector3i.ZERO:
		return Vector2i(999,999)
	return Vector2i(coords_3d.x,coords_3d.z)


func get_world_coords(tile_coords: Vector2i) -> Vector3:
	var tile_coords_3d = Vector3i(tile_coords.x, 0, tile_coords.y)
	var world_coords_3d = gridmap.map_to_local(tile_coords_3d)
	return Vector3(world_coords_3d.x,floor_height,world_coords_3d.z)


func _set_tilemap(value: TileMapLayer) -> void:
	tilemap = value
	TILE_SIZE = tilemap.tile_set.tile_size


func _set_gridmap(value: GridMap) -> void:
	gridmap = value
	var cell_size = gridmap.cell_size
	TILE_SIZE = Vector2(cell_size.x, cell_size.z)


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


func get_walkable_tiles(tiles: Array[Vector2i]) -> Array[Vector2i]:
	var walkable_tiles: Array[Vector2i] = []
	for tile in tiles:
		if not grid.is_point_solid(tile):
			walkable_tiles.append(tile)
	return walkable_tiles


func get_units(type: UnitType = UnitType.Any) -> Array[Node]:
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
	
	var used_tiles: Array[Vector2i] = []
	for tile in tiles:
		if grid.region.has_point(tile):
			used_tiles.append(tile)
	return used_tiles


func get_walkable_unit_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var units = get_units(UnitType.Any)
	for unit in units:
		var grid_pos = unit.grid_pos
		if not is_point_solid(grid_pos):
			tiles.append(grid_pos)
	return tiles
