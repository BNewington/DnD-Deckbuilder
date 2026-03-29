extends Node3D

@onready var grid_map: GridMap = $SubViewportContainer/SubViewport/GridMap
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/CameraPivot/Camera3D
@onready var turn_manager: TurnManager = $SubViewportContainer/SubViewport/TurnManager
@onready var menu_ui_layer = $MenuUILayer


func _ready() -> void:
	start_battle()
	menu_ui_layer.setup_card_pile_views()


func start_battle() -> void:
	Navigation.init(grid_map, camera_3d)
	Events.start_battle.emit()
	turn_manager.start_battle()
