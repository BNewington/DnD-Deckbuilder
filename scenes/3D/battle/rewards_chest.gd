class_name RewardsChest
extends Node3D

var grid_pos: Vector2i

func _ready() -> void:
	Events.start_battle.connect(_on_battle_started)
	Events.move_complete.connect(_on_move_complete)

func _on_battle_started() -> void:
	grid_pos = Navigation.get_tile_coords(global_position)
	print(grid_pos)


func _on_move_complete(unit: Unit) -> void:
	if unit.grid_pos == grid_pos:
		Events.reward_collected.emit(unit)
		queue_free()
