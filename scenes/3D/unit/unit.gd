extends Node3D

var tween: Tween
var floor_height = 2.267221

func move_to(target: Vector3i) -> void:
	var grid_pos = Navigation.gridmap.local_to_map(global_position)
	var flat_grid_pos = Vector2(grid_pos.x,grid_pos.z)
	var flat_target_pos = Vector2(target.x,target.z)
	var path = Navigation.get_cell_path(flat_grid_pos,flat_target_pos)
	if path:
		path.pop_front()
		tween = create_tween()
		for tile in path:
			var tile_3d = Vector3(tile.x, 0, tile.y)
			var next_pos = Navigation.gridmap.map_to_local(tile_3d)
			var flat_next_pos = Vector3(next_pos.x,floor_height,next_pos.z)
			tween.tween_property(self, "global_position",flat_next_pos,0.25)
		await tween.finished
