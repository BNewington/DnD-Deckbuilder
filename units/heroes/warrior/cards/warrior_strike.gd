extends Card

var reach := 1

func get_area() -> Array[Vector2i]:
	return Navigation.get_shape_tiles(Navigation.AreaShape.Square,reach,belongs_to.grid_pos)
