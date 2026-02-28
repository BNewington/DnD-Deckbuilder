class_name LowestHealth
extends AttackPriority

func filter_units(units: Array[Unit]) -> Array[Unit]:
	if units.size() <= 1:
		return units
		
	var lowest_health_units: Array[Unit] = [units[0]]
	units.pop_front()
	for unit in units:
		var current_unit_health = unit.stats.health
		var current_lowest_health = lowest_health_units[0].stats.health
		if current_unit_health < current_lowest_health:
			lowest_health_units = [unit]
		elif current_lowest_health == current_lowest_health:
			lowest_health_units.append(unit)
	
	return lowest_health_units
