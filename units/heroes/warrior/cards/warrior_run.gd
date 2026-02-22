extends Card

var speed = 3

func get_area() -> Array[Vector2i]:
	return Navigation.get_move_area(belongs_to.grid_pos,speed)


func execute(targets: Array) -> void:
	belongs_to.move_to(targets[0])
