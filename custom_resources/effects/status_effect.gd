class_name StatusEffect
extends TileEffect

@export var status: Status
@export var targets_self: bool = false

func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	if targets_self:
		unit.status_handler.add_status(status.duplicate())
		return
	
	for target in targets:
		var target_unit = Navigation.get_unit_at_tile(target)
		if target_unit:
			target_unit.status_handler.add_status(status.duplicate())
