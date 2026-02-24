extends Card


func execute(targets: Array) -> void:
	unit.attack(targets[0])
	var target_unit = Navigation.get_unit_at_tile(targets[0])
	if target_unit:
		target_unit.take_damage(5)
	
