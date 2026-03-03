class_name TileHighlights
extends Node3D

const TILE_HIGHLIGHT = preload("uid://dcerwhwrkdre3")

@export var cursor: Cursor
@export var highlight_colour: Color = Color(0.0, 0.71, 0.969, 0.553)

var selecting: bool = false
var selectable_tiles: Array[Vector2i]
var highlight_sprites: Array[MeshInstance3D]

func _ready() -> void:
	Events.card_aiming_started.connect(highlight_tiles)
	Events.card_aiming_ended.connect(clear_move_tiles)


func clear_move_tiles(_card_ui) -> void:
	clear_highlights(highlight_sprites)
	selecting = false
	selectable_tiles = []


func highlight_tiles(_card_ui: CardUI, tile_array: Array[Vector2i]) -> void:
	selectable_tiles = tile_array
	highlight_sprites = create_highlights_array(tile_array)
	selecting = true


func create_highlight(tile_coords: Vector2i) -> MeshInstance3D:
	var world_coords = Navigation.get_world_coords(tile_coords)
	var highlight = TILE_HIGHLIGHT.instantiate()
	highlight.position = world_coords
	add_child(highlight)
	return highlight


func create_highlights_array(tile_array: Array[Vector2i]) -> Array[MeshInstance3D]:
	var sprite_array: Array[MeshInstance3D] = []
	for tile in tile_array:
		sprite_array.append(create_highlight((tile)))
	return sprite_array


func clear_highlights(highlights) -> void:
	assert((highlights is MeshInstance3D) or (highlights is Array[MeshInstance3D]),
	"Unexpected type, must be Sprite2D or Array[Sprite2D]")
	
	if highlights is Array[MeshInstance3D]:
		for highlight in highlights:
			highlight.queue_free()
			
	elif highlights is MeshInstance3D:
		highlights.queue_free()
