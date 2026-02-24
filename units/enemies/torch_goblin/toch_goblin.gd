extends EnemyStats


func start_turn(unit: Unit):
	print(name," turn started")
	await unit.get_tree().create_timer(2).timeout
	print(name," turn over")
	Events.turn_ended.emit(unit)
