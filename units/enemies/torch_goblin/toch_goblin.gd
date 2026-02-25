extends EnemyStats


func start_turn(unit: Unit):
	print(name," turn started")
	await unit.get_tree().create_timer(1).timeout
	var pos = Navigation.get_tile_coords(unit.global_position)
	var target_tiles = find_target_tiles(unit)
	print("target tiles: ",target_tiles)
	if target_tiles.size() > 0:
		unit.move_to(target_tiles[0])
	await unit.get_tree().create_timer(1).timeout
	print(name," turn over")
	Events.turn_ended.emit(unit)
