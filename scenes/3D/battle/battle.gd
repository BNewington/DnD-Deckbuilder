extends Node3D

@onready var grid_map: GridMap = $SubViewportContainer/SubViewport/GridMap
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/CameraPivot/Camera3D


@onready var unit: Unit = $SubViewportContainer/SubViewport/TurnManager/Heroes/Unit
@onready var turn_manager: TurnManager = $SubViewportContainer/SubViewport/TurnManager

var floor_height = 1

func _ready() -> void:
	start_battle()


func start_battle() -> void:
	Navigation.init(grid_map, camera_3d)
	Events.start_battle.emit()
	turn_manager.start_battle()
