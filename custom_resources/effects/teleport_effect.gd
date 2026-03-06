class_name TeleportEffect
extends Effect


func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	var teleport_pos = Navigation.get_world_coords(targets[0])
	unit.global_position = teleport_pos
	Navigation.set_point_solid(unit.grid_pos)
	Navigation.set_point_walkable(targets[0])
