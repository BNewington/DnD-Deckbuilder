class_name Battle
extends Node3D

@onready var grid_map: GridMap = $SubViewportContainer/SubViewport/GridMap
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/CameraPivot/Camera3D
@onready var turn_manager: TurnManager = $SubViewportContainer/SubViewport/TurnManager
@onready var menu_ui_layer = $MenuUILayer

@onready var viewport: SubViewport = $SubViewportContainer/SubViewport


func start_battle(hero_stats: Array[HeroStats]) -> void:
	Navigation.init(grid_map, camera_3d)
	turn_manager.start_battle(hero_stats)
	Events.start_battle.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		take_screenshot()


func take_screenshot() -> void:
	var txt = viewport.get_viewport().get_texture() as ViewportTexture
	var image = txt.get_image() as Image
	image.save_png("screenshot.png")
	
	
	
	
