extends EnemyStats


func start_turn(unit: Unit):
	print(name," turn started")
	await unit.get_tree().create_timer(1).timeout
	var pos = Navigation.get_tile_coords(unit.global_position)
	print("target tiles: ",find_target_tiles(unit))
	unit.move_to(find_target_tiles(unit)[0])
	await unit.get_tree().create_timer(1).timeout
	print(name," turn over")
	Events.turn_ended.emit(unit)
