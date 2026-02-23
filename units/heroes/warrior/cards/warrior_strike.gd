extends Card

var reach := 1

func get_area() -> Array[Vector2i]:
	return Navigation.get_shape_tiles(Navigation.AreaShape.Square,reach,belongs_to.grid_pos)


func execute(targets: Array) -> void:
	belongs_to.attack(targets[0])
	var target_unit = Navigation.get_unit_at_tile(targets[0])
	if target_unit:
		target_unit.take_damage(5)
	
