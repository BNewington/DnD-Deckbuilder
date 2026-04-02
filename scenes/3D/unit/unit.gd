class_name Unit
extends Node3D


@export var stats: UnitStats : set = set_stats

@onready var placeholder_model: Node3D = $Knight_Hero
@onready var turn_indicator: MeshInstance3D = $TurnIndicator

var tween: Tween
var grid_pos: Vector2i : get = get_grid_pos
var target_pos: Vector2i

var floor_height = 1.118
var alive: bool = true

var model: Node3D


func _ready() -> void:
	Events.start_battle.connect(start_battle)
	Events.initiative_hovered.connect(initiative_hovered)
	Events.initiative_hovered_off.connect(initiative_hovered_off)
	$AnimationPlayer.play("spin")


func start_battle() -> void:
	Events.set_stats.emit(self, stats)
	global_position = Navigation.snap_to_grid(global_position)
	target_pos = grid_pos


func start_turn() -> void:
	turn_indicator.show()
	if stats is EnemyStats:
		var tile_coords = Navigation.get_tile_coords(global_position)
		Navigation.set_point_walkable(tile_coords)
	if stats is EnemyStats:
		stats.start_turn(self)


func end_turn() -> void:
	turn_indicator.hide()
	if stats is EnemyStats:
		Navigation.set_point_solid(target_pos)


func set_stats(value: UnitStats) -> void:
	if stats is HeroStats:
		stats = value
	else:
		stats = value.create_instance()
	update_hero()


func get_grid_pos() -> Vector2i:
	return Navigation.get_tile_coords(global_position)


func move_to(target: Vector2i) -> void:
	model.play_animation("Run")
	var path = Navigation.get_cell_path(grid_pos,target)
	target_pos = path[path.size()-1]
	if path:
		path.pop_front()
		tween = create_tween()
		for tile in path:
			var tile_3d = Vector3(tile.x, 0, tile.y)
			var next_pos = Navigation.gridmap.map_to_local(tile_3d)
			var flat_next_pos = Vector3(next_pos.x,floor_height,next_pos.z)
			tween.tween_callback(face_model.bind(flat_next_pos))
			tween.tween_property(self, "global_position",flat_next_pos,0.25)
		await tween.finished
		model.play_animation("Idle")
		Events.move_complete.emit(self)


func face_model(face_to: Vector3) -> void:
	model.look_at(face_to)


func attack(attack_pos) -> void:
	var world_attack_pos = Navigation.get_world_coords(attack_pos)
	face_model(world_attack_pos)
	model.play_animation("Attack")
	#TODO play attack animation
	pass


func update_hero() -> void:
	if not is_inside_tree():
		await ready
		
	model = stats.model.instantiate()
	model.scale = Vector3.ONE * 1.7
	add_child(model)
	placeholder_model.queue_free()
	if model.has_signal("animation_finished"):
		model.animation_finished.connect(on_animation_finished)
	model.play_animation("Idle")


func on_animation_finished(anim: String) -> void:
	if anim == "Attack":
		model.play_animation("Idle")


func initiative_hovered(unit: Unit) -> void:
	if unit == self:
		$Highlight.show()


func initiative_hovered_off(unit: Unit) -> void:
	if unit == self:
		$Highlight.hide()


func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	stats.take_damage(damage)
	
	if stats.health <= 0:
		die()


func die() -> void:
	Navigation.set_point_walkable(Navigation.get_tile_coords(global_position))
	alive = false
	Events.unit_died.emit(self)
	queue_free()
