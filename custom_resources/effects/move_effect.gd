class_name MoveEffect
extends Effect


func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	unit.move_to(targets[0])
