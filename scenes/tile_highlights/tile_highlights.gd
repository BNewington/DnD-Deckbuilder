class_name TileHighlights
extends Node3D

const TILE_HIGHLIGHT = preload("uid://dcerwhwrkdre3")
const TILE_GREY_OUT = preload("uid://lr37brw4eqfi")

@onready var tile_selector: Node3D = $TileSelector

@export var cursor: Cursor
@export var highlight_colour: Color = Color(0.0, 0.71, 0.969, 0.553)

var vertical_offset = Vector3(0,1.14,0)

var selecting: bool = false
var selectable_tiles: Array[Vector2i]
var area_tiles: Array[Vector2i]
var highlight_sprites: Array[MeshInstance3D]
var greyed_out_sprites: Array[MeshInstance3D]

func _process(_delta: float) -> void:
	var mouse_pos = Navigation.find_3d_mouse_pos()
	var tile_over = Navigation.get_tile_coords(mouse_pos)
	if tile_over in selectable_tiles:
		tile_selector.show()
		tile_selector.global_position = Navigation.get_world_coords(tile_over)
	else:
		tile_selector.hide()

func _ready() -> void:
	Events.card_aiming_started.connect(highlight_tiles)
	Events.card_aiming_ended.connect(clear_move_tiles)


func clear_move_tiles(_card_ui) -> void:
	clear_highlights(highlight_sprites)
	selecting = false
	selectable_tiles = []


func highlight_tiles(_card_ui: CardUI, tile_array: Array[Vector2i], valid_targets: Array[Vector2i]) -> void:
	selectable_tiles = valid_targets
	area_tiles = tile_array
	highlight_sprites = create_highlights_array(selectable_tiles,area_tiles)
	selecting = true


func create_highlight(tile_coords: Vector2i, selectable: bool) -> MeshInstance3D:
	var world_coords = Navigation.get_world_coords(tile_coords)
	var highlight: MeshInstance3D
	if selectable:
		highlight = TILE_HIGHLIGHT.instantiate()
	else:
		highlight = TILE_GREY_OUT.instantiate()
	highlight.position = world_coords - vertical_offset
	add_child(highlight)
	return highlight


func create_highlights_array(selectables: Array[Vector2i], tile_array: Array[Vector2i]) -> Array[MeshInstance3D]:
	var sprite_array: Array[MeshInstance3D] = []
	for tile in tile_array:
		var selectable: bool = tile in selectables
		sprite_array.append(create_highlight(tile, selectable))
	return sprite_array


func clear_highlights(highlights) -> void:
	assert((highlights is MeshInstance3D) or (highlights is Array[MeshInstance3D]),
	"Unexpected type, must be Sprite2D or Array[Sprite2D]")
	
	if highlights is Array[MeshInstance3D]:
		for highlight in highlights:
			highlight.queue_free()
			
	elif highlights is MeshInstance3D:
		highlights.queue_free()
