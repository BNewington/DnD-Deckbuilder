class_name EnemyStats
extends UnitStats

@export var move_priorities: Array[MovePriority]

func find_target_tiles(unit: Unit) -> Array[Vector2i]:
	var tiles = Navigation.get_all_tiles()
	for priority in move_priorities:
		tiles = priority.filter_tiles(unit, tiles)
	return tiles
