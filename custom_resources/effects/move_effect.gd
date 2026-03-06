class_name MoveEffect
extends Effect


func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	var grid_pos = unit.grid_pos
	var solid = Navigation.is_point_solid(grid_pos)
	if solid:
		Navigation.set_point_walkable(grid_pos)
		unit.move_to(targets[0])
		Navigation.set_point_solid(grid_pos)
	else:
		unit.move_to(targets[0])
