class_name BlockEffect
extends TileEffect


@export var amount: int


func execute(unit: Unit, _targets: Array[Vector2i]) -> void:
	var modifiers := unit.modifier_handler
	var modified_amount = modifiers.get_modified_value(amount, Modifier.Type.BLOCK_GAINED)
	unit.stats.block += modified_amount
