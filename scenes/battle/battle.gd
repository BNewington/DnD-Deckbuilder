extends Node2D

@onready var turn_manager: TurnManager = $TurnManager
@onready var ground_tiles: TileMapLayer = %GroundTiles

func _ready() -> void:
	Events.hero_turn_ended.connect(turn_manager.end_turn)
	Events.hand_discarded.connect(turn_manager.start_turn)
	start_battle()


func start_battle() -> void:
	Navigation.init_level(ground_tiles)
	Events.start_battle.emit()
	turn_manager.start_battle()
