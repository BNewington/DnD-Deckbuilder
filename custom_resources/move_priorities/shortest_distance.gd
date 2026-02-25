class_name ShortestDistance
extends MovePriority

func filter_tiles(unit: Unit, tiles: Array[Vector2i]) -> Array[Vector2i]:
	var position = Navigation.get_tile_coords(unit.global_position)
	return Navigation.find_closest_tiles(position,tiles)
 
