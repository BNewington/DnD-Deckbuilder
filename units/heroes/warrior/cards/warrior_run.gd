extends Card

var speed = 3

func get_area() -> Array[Vector2i]:
	return Navigation.get_move_area(unit.grid_pos,speed)


func execute(targets: Array) -> void:
	unit.move_to(targets[0])
