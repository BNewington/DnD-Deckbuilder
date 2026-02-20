extends Card

var speed = 3

func get_area(hero_pos) -> Array[Vector2i]:
	return Navigation.get_move_area(hero_pos,speed)
