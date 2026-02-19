extends Node2D

@onready var icon: Sprite2D = $Icon

func _ready() -> void:
	Navigation.init_level($GroundTiles)
	Events.start_battle.emit()
	var player_pos = Navigation.get_tile_coords($Unit.global_position)
	var moveable_tiles = Navigation.get_move_area(player_pos, 3)
	$TileHighlights.create_highlights_array(moveable_tiles)

func _process(_delta: float) -> void:
	icon.global_position = Navigation.snap_to_grid(get_global_mouse_position())
