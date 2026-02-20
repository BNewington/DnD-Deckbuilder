extends Card

var reach := 1

func get_area(hero_pos) -> Array[Vector2i]:
	return Navigation.get_shape_tiles(Navigation.AreaShape.Square,reach,hero_pos)
