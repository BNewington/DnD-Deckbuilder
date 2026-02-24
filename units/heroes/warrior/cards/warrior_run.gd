extends Card

var speed = 3


func execute(targets: Array) -> void:
	unit.move_to(targets[0])
