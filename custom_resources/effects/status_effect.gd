class_name StatusEffect
extends TileEffect

@export var status: Status

func execute(_unit: Unit, targets: Array[Vector2i]) -> void:
	for target in targets:
		var target_unit = Navigation.get_unit_at_tile(target)
		if target_unit:
			target_unit.status_handler.add_status(status.duplicate())
