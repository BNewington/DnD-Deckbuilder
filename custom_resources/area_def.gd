class_name AreaDef
extends Resource

enum OriginType {UNIT, LAST_SELECTED_TILE}

@export var shape: Navigation.AreaShape
@export var radius: int
@export var origin_type: OriginType
@export var direction: Navigation.Direction
@export var move: bool = false
@export var include_target: bool = false


func get_area(origin_pos: Vector2i) -> Array[Vector2i]:
	if move:
		return Navigation.get_move_area(origin_pos,radius)
		
	return Navigation.get_shape_tiles(shape,radius,origin_pos,include_target,direction)
