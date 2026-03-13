class_name DamageEffect
extends TileEffect

@export var amount: int = 0

func execute(unit: Unit, targets: Array[Vector2i]) -> void:
	print(targets)
	unit.attack(targets[0])
	for target in targets:
		var target_unit = Navigation.get_unit_at_tile(target)
		if target_unit:
			target_unit.take_damage(amount)
