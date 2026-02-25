extends EnemyStats


func start_turn(unit: Unit):
	print(name," turn started")
	await unit.get_tree().create_timer(2).timeout
	var pos = Navigation.get_tile_coords(unit.global_position)
	print(Navigation.get_nearest(pos,Navigation.UnitType.Hero))
	print(name," turn over")
	print(move_priorities[0].filter_tiles(Navigation.get_all_tiles()))
	Events.turn_ended.emit(unit)
