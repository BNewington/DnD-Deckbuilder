class_name ClosestToHero
extends MovePriority


func filter_tiles(_unit: Unit, tiles: Array[Vector2i]) -> Array[Vector2i]:
	var heroes = Navigation.get_units(Navigation.UnitType.Hero)
	var closest_tiles: Dictionary = {}
	Navigation.set_units_solid(Navigation.UnitType.Hero,false)
	for hero in heroes:
		var hero_pos = Navigation.get_tile_coords(hero.global_position)
		if hero_pos in tiles: tiles.erase(hero_pos)
		var closest_tiles_to_hero = Navigation.find_closest_tiles(hero_pos,tiles)
		var distance_to_tiles: int
		if closest_tiles_to_hero.size() == 0:
			distance_to_tiles = 999
		else:
			distance_to_tiles = len(Navigation.get_cell_path(closest_tiles_to_hero[0],hero_pos))
		
		if distance_to_tiles in closest_tiles.keys():
			closest_tiles[distance_to_tiles].append(closest_tiles_to_hero)
		else:
			closest_tiles[distance_to_tiles] = closest_tiles_to_hero
	
	Navigation.set_units_solid(Navigation.UnitType.Hero,false)
	
	
	var keys = closest_tiles.keys()
	if len(keys) == 1 and keys.max() == 999:
		return tiles
	else:
		return closest_tiles[keys.min()]
