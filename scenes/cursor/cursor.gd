class_name Cursor
extends Node2D

enum CursorType {
	Pointer,
	Hand,
	Disabled,
	TileSelector
}

var current_type: CursorType = CursorType.Pointer
var SNAP_THRESHOLD: float = 0.4
var current_cell: Vector2i
var cell_last_frame: Vector2i
var tile_selector_enabled: bool = false

@onready var pointer_sprite: Sprite2D = $Sprites/PointerSprite
@onready var hand_sprite: Sprite2D = $Sprites/HandSprite
@onready var disabled_sprite: Sprite2D = $Sprites/DisabledSprite
@onready var tile_selector_sprite: Sprite2D = $Sprites/TileSelectorSprite
@onready var mobile_cursors: Array[Sprite2D] = [pointer_sprite, hand_sprite, disabled_sprite]
@onready var areas: Node2D = $Areas


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Events.cursor_mode_pointer.connect(enable_pointer)
	Events.cursor_mode_hand.connect(enable_hand)
	Events.cursor_mode_disabled.connect(disable_cursor)
	Events.show_tile_selector.connect(enable_tile_selector)
	enable_pointer()


func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	current_cell = Navigation.get_tile_coords(mouse_pos)
	move_cursor(mouse_pos)
	cell_last_frame = current_cell



func move_cursor(mouse_pos: Vector2) -> void:
	for cursor in mobile_cursors:
		cursor.global_position = mouse_pos
		areas.global_position = mouse_pos
		
	if tile_selector_enabled:
		var snapped_pos = Navigation.snap_to_grid(mouse_pos)
		tile_selector_sprite.global_position = lerp(tile_selector_sprite.global_position,snapped_pos,0.2)


func enable_pointer() -> void:
	hand_sprite.hide()
	disabled_sprite.hide()
	pointer_sprite.show()


func enable_hand() -> void:
	pointer_sprite.hide()
	disabled_sprite.hide()
	hand_sprite.show()


func disable_cursor() -> void:
	pointer_sprite.hide()
	hand_sprite.hide()
	disabled_sprite.show()


func enable_tile_selector() -> void:
	tile_selector_sprite.show()
	tile_selector_enabled = true


func disable_tile_selector() -> void:
	tile_selector_sprite.hide()
	tile_selector_enabled = false
