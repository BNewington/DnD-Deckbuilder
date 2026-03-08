class_name MoveOtherEffect
extends Effect

@export var mover_area_id: int = 0

func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	var mover = 
	unit.move_to(targets[0])
