class_name TeleportEffect
extends Effect


func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	var teleport_pos = Navigation.get_world_coords(targets[0])
	Navigation.set_point_walkable(unit.grid_pos)
	unit.global_position = teleport_pos
	unit.target_pos = Navigation.get_tile_coords(teleport_pos)
	Navigation.set_point_solid(unit.grid_pos)
