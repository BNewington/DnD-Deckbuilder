class_name AreaDef
extends Resource


@export var shape: Navigation.AreaShape
@export var radius: int
@export var direction: Navigation.Direction
@export var move: bool = false
@export var include_target: bool = false


func get_area(origin: Vector2i) -> Array[Vector2i]:
	if move:
		return Navigation.get_move_area(origin,radius)
		
	return Navigation.get_shape_tiles(shape,radius,origin,include_target,direction)
