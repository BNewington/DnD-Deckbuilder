extends Status

func apply_status(target: Unit) -> void:
	target.take_damage(stacks)
	status_applied.emit(self)
