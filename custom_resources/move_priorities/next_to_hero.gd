class_name NextToHero
extends MovePriority

@export var include_diagonals: bool = true

var adjacent_tiles = [Vector2i(0,1),Vector2i(0,-1),Vector2i(1,0),Vector2i(-1,0)]
var diagonal_tiles = [Vector2i(1,1),Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-1,1)]

func filter_tiles(unit: Unit, tiles: Array[Vector2i]) -> Array[Vector2i]:
	var search_tiles = []
	if include_diagonals:
		search_tiles = adjacent_tiles + diagonal_tiles
	else:
		search_tiles = adjacent_tiles
	
	var filtered_tiles: Array[Vector2i] = []
	for tile in tiles:
		for hero in _get_heroes(unit):
			var current_tile: Vector2i
			for search_tile in search_tiles:
				current_tile = search_tile + Navigation.get_tile_coords(hero.global_position)
				if current_tile == tile:
					filtered_tiles.append(current_tile)
	
	return filtered_tiles
