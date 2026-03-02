extends Node3D

@onready var grid_map: GridMap = $SubViewportContainer/SubViewport/GridMap
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/Camera3D

var floor_height = 2.267221

func _ready() -> void:
	Navigation.init(grid_map, camera_3d)


func _process(delta: float) -> void:
	var mouse_pos = Navigation.find_3d_mouse_pos()
	var grid_pos = grid_map.local_to_map(mouse_pos)
	var local_pos = grid_map.map_to_local(grid_pos)
	var flattened_pos = Vector3(local_pos.x,floor_height,local_pos.z)
	$SubViewportContainer/SubViewport/Unit.global_position = flattened_pos
