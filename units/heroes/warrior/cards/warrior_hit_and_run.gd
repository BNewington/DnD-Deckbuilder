extends Card


func execute(area_id: int, targets: Array) -> void:
	if area_id == 0:
		unit.attack(targets[0])
		var target_unit = Navigation.get_unit_at_tile(targets[0])
		if target_unit:
			target_unit.take_damage(4)
	elif area_id == 1:
		unit.move_to(targets[0])
