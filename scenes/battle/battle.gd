extends Node2D

@onready var icon: Sprite2D = $Icon

func _ready() -> void:
	Navigation.init_level($GroundTiles)
	Events.start_battle.emit()

func _process(_delta: float) -> void:
	icon.global_position = Navigation.snap_to_grid(get_global_mouse_position())
