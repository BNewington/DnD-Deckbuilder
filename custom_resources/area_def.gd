class_name AreaDef
extends Resource

enum OriginType {UNIT, LAST_SELECTED_TILE}
enum TargetType {AREA, SELF, UNIT, HERO, ENEMY}
enum ValidTargets {ANY_TILE, WALKABALE_TILE, UNIT, HERO, ENEMY}


@export var valid_targets: ValidTargets = ValidTargets.ENEMY
@export var selection: TargetType = TargetType.AREA
@export var shape: Navigation.AreaShape
@export var radius: int
@export var origin_type: OriginType
@export var move: bool = false
@export var include_target: bool = false
@export var effects: Array[Effect]
@export var can_cancel_after: bool = true


func get_area(origin_pos: Vector2i) -> Array[Vector2i]:
	Navigation.set_units_solid(Navigation.UnitType.Any)
	Navigation.set_point_walkable(origin_pos)
	var area: Array[Vector2i] = []
	match selection:
		TargetType.SELF:
			return [origin_pos]
		TargetType.UNIT, TargetType.ENEMY, TargetType.HERO:
			var unit_type = _get_unit_type(selection)
			var units = Navigation.get_units(unit_type)
			for unit in units:
				area.append(unit.grid_pos)
		TargetType.AREA:
			if move: 
				area = Navigation.get_move_area(origin_pos,radius)
			else:
				area = Navigation.get_shape_tiles(shape,radius,origin_pos,include_target)
	
	return area


func get_valid_target_cells(area: Array[Vector2i]) -> Array[Vector2i]:
	var target_cells: Array[Vector2i] = []
	match valid_targets:
		ValidTargets.UNIT, ValidTargets.ENEMY, ValidTargets.HERO:
			var unit_type: Navigation.UnitType
			if valid_targets == ValidTargets.UNIT: unit_type = Navigation.UnitType.Any
			elif valid_targets == ValidTargets.HERO: unit_type = Navigation.UnitType.Hero
			elif valid_targets == ValidTargets.ENEMY: unit_type = Navigation.UnitType.Enemy
			var units = Navigation.get_units(unit_type)
			for unit in units:
				target_cells.append(unit.grid_pos)
		
		ValidTargets.ANY_TILE:
			target_cells = area
		
		ValidTargets.WALKABALE_TILE:
			for cell in area:
				if not Navigation.is_point_solid(cell):
					target_cells.append(cell)
				else:
					print(cell," is solid")
	
	
	var valid_target_cells: Array[Vector2i]
	for cell in area:
		if cell in target_cells:
			valid_target_cells.append(cell)
	
	return valid_target_cells



func _get_unit_type(type: TargetType) -> Navigation.UnitType:
	var unit_type: Navigation.UnitType
	if type == TargetType.UNIT: unit_type = Navigation.UnitType.Any
	elif type == TargetType.HERO: unit_type = Navigation.UnitType.Hero
	elif type == TargetType.ENEMY: unit_type = Navigation.UnitType.Enemy
	return unit_type


func requires_aiming() -> bool:
	match selection:
		TargetType.AREA, TargetType.UNIT, TargetType.ENEMY, TargetType.HERO:
			return true
		_:
			return false
