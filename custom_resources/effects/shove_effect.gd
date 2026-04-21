class_name ShoveEffect
extends TileEffect

@export var amount: int = 1

func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	for target in targets:
		var unit_at_tile = Navigation.get_unit_at_tile(target)
		if unit_at_tile:
			unit_at_tile.shove(unit.grid_pos, amount)
