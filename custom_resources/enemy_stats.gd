class_name EnemyStats
extends UnitStats

@export_category("Movement")
@export var move_speed: int = 3
@export var move_priorities: Array[MovePriority]
@export_category("Attacks")
@export var attack_range: int = 1
@export var attack_priorities: Array[AttackPriority]


func find_target_tiles(unit: Unit) -> Array[Vector2i]:
	var unit_pos = Navigation.get_tile_coords(unit.global_position)
	var tiles = Navigation.get_walkable_tiles(Navigation.get_move_area(unit_pos,move_speed))
	tiles.append(unit_pos)
	
	for priority in move_priorities:
		var filtered_tiles = priority.filter_tiles(unit, tiles)
		if filtered_tiles != []:
			tiles = filtered_tiles
	return tiles


func find_target_units(unit: Unit) -> Array[Unit]:
	var unit_pos = Navigation.get_tile_coords(unit.global_position)
	var tiles = Navigation.get_shape_tiles(Navigation.AreaShape.Square,attack_range,unit_pos)
	var units: Array[Unit] = []
	for tile in tiles:
		var unit_at_tile = Navigation.get_unit_at_tile(tile)
		if unit_at_tile and unit_at_tile.stats is HeroStats:
			if unit.status_handler.has_status("taunt") and unit_at_tile.stats.type != HeroStats.HeroType.Warrior:
				pass
			else:
				units.append(unit_at_tile)
	
	for priority in attack_priorities:
		units = priority.filter_units(units)
	return units



func start_turn(unit: Unit) -> void:
	await unit.get_tree().create_timer(1).timeout
	
	#Move
	var pos = Navigation.get_tile_coords(unit.global_position)
	var target_tiles = find_target_tiles(unit)
	if target_tiles.size() > 0 and not pos in target_tiles:
		unit.move_to(target_tiles[0])
	
	await unit.get_tree().create_timer(1).timeout
	
	var target_units = find_target_units(unit)
	if target_units.size() > 0:
		unit.attack(target_units[0].grid_pos)
		target_units[0].take_damage(5) #TODO replace this with a flexible attack system
	
	Events.turn_ended.emit(unit)
