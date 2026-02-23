extends Node2D

@onready var turn_manager: TurnManager = $TurnManager
@onready var ground_tiles: TileMapLayer = %GroundTiles

func _ready() -> void:
	start_battle()


func start_battle() -> void:
	Navigation.init_level(ground_tiles)
	Events.start_battle.emit()
	turn_manager.start_battle()
