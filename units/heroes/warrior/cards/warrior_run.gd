extends Card


func execute(area_id: int, targets: Array) -> void:
	unit.move_to(targets[0])
