class_name Unit
extends Node3D


@export var stats: UnitStats : set = set_stats

@onready var stats_ui: StatsUI = $StatsUI as StatsUI
@onready var placeholder_model: Node3D = $Knight_Hero
@onready var turn_indicator: MeshInstance3D = $TurnIndicator

var tween: Tween
var grid_pos: Vector2i : get = get_grid_pos
var target_pos: Vector2i

var floor_height = 1


func _ready() -> void:
	Events.start_battle.connect(start_battle)
	$AnimationPlayer.play("spin")


func start_battle() -> void:
	Events.set_stats.emit(self, stats)
	global_position = Navigation.snap_to_grid(global_position)
	target_pos = grid_pos


func start_turn() -> void:
	turn_indicator.show()
	var tile_coords = Navigation.get_tile_coords(global_position)
	Navigation.set_point_walkable(tile_coords)
	if stats is EnemyStats:
		stats.start_turn(self)
	print(Navigation.find_2d_screen_pos(global_position))


func end_turn() -> void:
	turn_indicator.hide()
	Navigation.set_point_solid(target_pos)


func set_stats(value: UnitStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	
	update_hero()


func get_grid_pos() -> Vector2i:
	return Navigation.get_tile_coords(global_position)



func move_to(target: Vector2i) -> void:
	var path = Navigation.get_cell_path(grid_pos,target)
	target_pos = path[path.size()-1]
	if path:
		path.pop_front()
		tween = create_tween()
		for tile in path:
			var tile_3d = Vector3(tile.x, 0, tile.y)
			var next_pos = Navigation.gridmap.map_to_local(tile_3d)
			var flat_next_pos = Vector3(next_pos.x,floor_height,next_pos.z)
			tween.tween_property(self, "global_position",flat_next_pos,0.15)
		await tween.finished


	

func attack(attack_pos) -> void:
	#TODO play attack animation
	pass


func update_hero() -> void:
	if not is_inside_tree():
		await ready
		
	update_stats()
	var model = stats.model.instantiate()
	model.scale = Vector3.ONE * 2
	add_child(model)
	placeholder_model.queue_free()


func update_stats() -> void: #should emit a signal telling the battleui to update stats
	stats_ui.update_stats(stats)


func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	stats.take_damage(damage)
	
	if stats.health <= 0:
		die()


func die() -> void:
	Navigation.set_point_walkable(Navigation.get_tile_coords(global_position))
	Events.unit_died.emit(self)
	queue_free()
