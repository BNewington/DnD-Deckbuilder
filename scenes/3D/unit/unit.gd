class_name Unit
extends Node3D

@export var stats: UnitStats : set = set_stats

@onready var placeholder_model: Node3D = $GoblinModel
@onready var turn_indicator: MeshInstance3D = $TurnIndicator
@onready var modifier_handler: ModifierHandler = $ModifierHandler


var status_handler: StatusHandler : set = set_status_handler

var tween: Tween
var grid_pos: Vector2i : get = get_grid_pos
var target_pos: Vector2i

var floor_height = 1.118
var alive: bool = true

var model: Node3D

var card_aiming: bool = false

func _ready() -> void:
	Events.start_battle.connect(start_battle)
	Events.initiative_hovered.connect(initiative_hovered)
	Events.initiative_hovered_off.connect(initiative_hovered_off)
	Events.unit_hovered.connect(_on_unit_hovered)
	Events.unit_hovered_off.connect(_on_unit_hovered_off)
	
	Events.card_aiming_started.connect(_on_card_aiming_started)
	Events.card_aiming_ended.connect(_on_card_aiming_ended)
	$AnimationPlayer.play("spin")


func set_status_handler(value: StatusHandler) -> void:
	status_handler = value
	status_handler.statuses_applied.connect(_on_statuses_applied)


func start_battle() -> void:
	Events.set_stats.emit(self, stats)
	global_position = Navigation.snap_to_grid(global_position)
	target_pos = grid_pos


func start_turn() -> void:
	turn_indicator.show()
	status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)
	stats.block = 0


func _on_statuses_applied(type: Status.Type) -> void:
	if type == Status.Type.START_OF_TURN:
		if stats is EnemyStats:
			var tile_coords = Navigation.get_tile_coords(global_position)
			Navigation.set_point_walkable(tile_coords)
		if stats is EnemyStats:
			stats.start_turn(self)


func end_turn() -> void:
	status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)
	status_handler.count_down_duration_statuses()
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
	model.scale = Vector3.ONE * 1.3
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
	var modified_damage = modifier_handler.get_modified_value(damage, Modifier.Type.DMG_TAKEN)
	if stats.health <= 0:
		return
	
	stats.take_damage(modified_damage)
	
	if stats.health <= 0:
		die()


func die() -> void:
	Navigation.set_point_walkable(Navigation.get_tile_coords(global_position))
	alive = false
	Events.unit_died.emit(self)
	queue_free()


func _on_unit_hovered(unit: Unit) -> void:
	if unit == self and stats is EnemyStats and not card_aiming:
		Navigation.set_units_solid(Navigation.UnitType.Any)
		Navigation.set_point_walkable(grid_pos)
		var tiles = stats.find_target_tiles(self)
		var path = Navigation.get_cell_path(grid_pos,tiles[0])
		var target_units = stats.find_target_units(self, tiles[0])
		var target_tiles: Array[Vector2i] = [target_units[0].grid_pos]
		Events.request_tile_highlights.emit(path+target_tiles, target_tiles)


func _on_unit_hovered_off(unit: Unit) -> void:
	if unit == self and stats is EnemyStats and not card_aiming:
		Events.clear_tile_highlights.emit()


func _on_card_aiming_started(tiles: Array[Vector2i], valid_targets: Array[Vector2i]) -> void:
	card_aiming = true


func _on_card_aiming_ended() -> void:
	card_aiming = false
