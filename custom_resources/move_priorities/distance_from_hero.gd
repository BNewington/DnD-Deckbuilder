class_name DistanceFromHero
extends MovePriority

enum ComparatorType {GREATER_THAN, EQUAL_TO, LESS_THAN}

@export var comparator: ComparatorType
@export var value: int


func filter_tiles(_unit: Unit, tiles: Array[Vector2i]) -> Array[Vector2i]:
	Navigation.set_units_solid(Navigation.UnitType.Hero,false)
	var valid_tiles: Array[Vector2i] = []
	for tile in tiles:
		var distances_to_heroes = find_distances_to_heroes(tile, Navigation.get_units(Navigation.UnitType.Hero))
		if is_valid(distances_to_heroes):
			valid_tiles.append(tile)
	Navigation.set_units_solid(Navigation.UnitType.Hero,true)
	
	if valid_tiles.size() > 0:
		return valid_tiles
	return tiles


func find_distances_to_heroes(tile: Vector2i, heroes: Array[Node]) -> Array[int]:
	var distances: Array[int] = []
	for hero: Unit in heroes:
		var distance = Navigation.get_cell_path(tile, hero.grid_pos).size() - 1
		distances.append(distance)
	return distances


func is_valid(distances: Array[int]) -> bool:
	for distance in distances:
		match comparator:
			ComparatorType.GREATER_THAN:
				if distance > value:
					return true
			ComparatorType.LESS_THAN:
				if distance < value:
					return true
			ComparatorType.EQUAL_TO:
				if distance == value:
					return true
	return false
