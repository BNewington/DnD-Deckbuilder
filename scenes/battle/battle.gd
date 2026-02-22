extends Node2D

@onready var icon: Sprite2D = $Icon
var warrior_run_card = preload("uid://cql3oentr77yy")
var warrior_strike_card = preload("uid://cxn8jc3q4tmel")

func _ready() -> void:
	Navigation.init_level($GroundTiles)
	Events.start_battle.emit()
	warrior_run_card.belongs_to = $Unit
	warrior_strike_card.belongs_to = $Unit

func _process(_delta: float) -> void:
	icon.global_position = Navigation.snap_to_grid(get_global_mouse_position())
