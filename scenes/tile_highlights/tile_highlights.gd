class_name TileHighlights
extends Node2D

const TILE_HIGHLIGHT = preload("uid://ufqfkdc3ktgr")

@export var cursor: Cursor
@export var highlight_colour: Color = Color(0.0, 0.71, 0.969, 0.553)


func create_highlight(tile_coords: Vector2i) -> Sprite2D:
	var world_coords = Navigation.get_world_coords(tile_coords)
	var highlight = Sprite2D.new()
	highlight.texture = TILE_HIGHLIGHT
	highlight.position = world_coords
	highlight.modulate = highlight_colour
	highlight.z_index = 1
	add_child(highlight)
	return highlight


func create_highlights_array(tile_array: Array[Vector2i]) -> Array[Sprite2D]:
	var sprite_array: Array[Sprite2D] = []
	for tile in tile_array:
		sprite_array.append(create_highlight((tile)))
	return sprite_array


func clear_highlights(highlights) -> void:
	assert((highlights is Sprite2D) or (highlights is Array[Sprite2D]),
	"Unexpected type, must be Sprite2D or Array[Sprite2D]")
	
	if highlights is Array[Sprite2D]:
		for highlight in highlights:
			highlight.queue_free()
			
	elif highlights is Sprite2D:
		highlights.queue_free()
