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
@onready var mobile_cursors: Array[Sprite2D] = [pointer_sprite, hand_sprite, disabled_sprite]
@onready var areas: Node2D = $Areas
@onready var area_2d: Area2D = $Areas/Area2D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	connect_events()
	enable_pointer()

func connect_events() -> void:
	Events.cursor_mode_pointer.connect(enable_pointer)
	Events.cursor_mode_hand.connect(enable_hand)
	Events.cursor_mode_disabled.connect(disable_cursor)
	Events.card_dragging_started.connect(card_dragging_started)
	Events.card_dragging_ended.connect(card_dragging_ended)
	Events.card_aiming_started.connect(card_aiming_started)
	Events.card_aiming_ended.connect(card_aiming_ended)


func card_aiming_started(_card_ui: CardUI, _tiles: Array[Vector2i]) -> void:
	area_2d.monitorable = false
	area_2d.monitoring = false


func card_aiming_ended(_card_ui: CardUI) -> void:
	area_2d.monitorable = true
	area_2d.monitoring = true


func card_dragging_started(_card_ui: CardUI) -> void:
	area_2d.monitorable = false
	area_2d.monitoring = false


func card_dragging_ended(_card_ui: CardUI) -> void:
	area_2d.monitorable = true
	area_2d.monitoring = true


func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	current_cell = Navigation.get_tile_coords(Navigation.find_3d_mouse_pos())
	move_cursor(mouse_pos)
	cell_last_frame = current_cell


func move_cursor(mouse_pos: Vector2) -> void:
	for cursor in mobile_cursors:
		cursor.global_position = mouse_pos
		areas.global_position = mouse_pos
		


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
