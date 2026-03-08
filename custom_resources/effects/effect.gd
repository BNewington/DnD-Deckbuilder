class_name Effect
extends Resource

enum ExecutorType {SELF, PREVIOUSLY_SELECTED_UNIT}

@export var executor: ExecutorType = ExecutorType.SELF
@export var executor_id: int = 0

func execute(_unit: Unit, _targets: Array[Vector2i]) -> void:
	pass
