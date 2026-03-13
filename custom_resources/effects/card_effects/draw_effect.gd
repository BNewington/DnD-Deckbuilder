extends CardEffect
class_name DrawEffect

@export var amount: int = 1

func execute(unit: Unit) -> void:
	for i in range(amount):
		Events.draw_card.emit(unit.stats)
