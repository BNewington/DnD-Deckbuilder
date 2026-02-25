class_name EnemyStats
extends UnitStats

@export var move_speed: int = 3
@export var move_priorities: Array[MovePriority]

func find_target_tiles(unit: Unit) -> Array[Vector2i]:
	var unit_pos = Navigation.get_tile_coords(unit.global_position)
	var tiles = Navigation.get_walkable_tiles(Navigation.get_move_area(unit_pos,move_speed))
	
	for priority in move_priorities:
		tiles = priority.filter_tiles(unit, tiles)
	return tiles
