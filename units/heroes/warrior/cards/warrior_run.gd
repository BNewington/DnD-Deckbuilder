extends Card


func execute(targets: Array) -> void:
	unit.move_to(targets[0])
