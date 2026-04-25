class_name StatusEffect
extends TileEffect

@export var status: Status
@export var targets_self: bool = false
@export var amount: int = 1

func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	var new_status = status.duplicate()
	if new_status.stack_type == Status.StackType.INTENSITY:
		new_status.stacks = amount
	elif new_status.stack_type == Status.StackType.DURATION:
		new_status.duration = amount
		
	if targets_self:
		unit.status_handler.add_status(new_status)
		return
	
	for target in targets:
		var target_unit = Navigation.get_unit_at_tile(target)
		if target_unit:
			target_unit.status_handler.add_status(new_status)
