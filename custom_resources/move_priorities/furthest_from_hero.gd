class_name FurthestFromHero
extends MovePriority

#find the tile with the greatest min distance to a hero
func filter_tiles(unit: Unit, tiles: Array[Vector2i]) -> Array[Vector2i]:
	Navigation.set_units_solid(Navigation.UnitType.Hero,false)
	var furthest_tiles: Array[Vector2i] = [tiles[0]]
	for tile in tiles:
		var hero_distance = find_closest_hero_distance(unit, tile)
		var furthest_distance = find_closest_hero_distance(unit, furthest_tiles[0])
		if hero_distance > furthest_distance:
			furthest_tiles = [tile]
		elif hero_distance == furthest_distance:
			furthest_tiles.append(tile)
	Navigation.set_units_solid(Navigation.UnitType.Hero)
	return furthest_tiles
	


func find_closest_hero_distance(unit: Unit, tile: Vector2i) -> int:
	var closest_distance: int = 999
	for hero: Unit in _get_heroes(unit):
		var distance = Navigation.get_distance(tile, hero.grid_pos)
		if distance < closest_distance:
			closest_distance = distance
	return closest_distance
