class_name Unit
extends Area2D

@export var stats: HeroStats : set = set_stats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats_ui: StatsUI = $StatsUI as StatsUI


var tween: Tween
var grid_pos: Vector2i : get = get_grid_pos


func _ready() -> void:
	Events.start_battle.connect(start_battle)

func start_battle() -> void:
	global_position = Navigation.snap_to_grid(global_position)

func set_stats(value: HeroStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	
	update_hero()


func get_grid_pos() -> Vector2i:
	return Navigation.get_tile_coords(global_position)


func move_to(target: Vector2i) -> void:
	var path = Navigation.get_cell_path(Navigation.get_tile_coords(global_position),target)
	if path:
		path.pop_front()
		tween = create_tween()
		sprite.play("run")
		for tile in path:
			var next_pos = Navigation.get_world_coords(tile)
			tween.tween_callback(face_sprite.bind(next_pos))
			tween.tween_property(self, "global_position",next_pos,0.25)
		await tween.finished
		sprite.play("idle")


func face_sprite(face_to: Vector2) -> void:
	if global_position.x > face_to.x:
		sprite.flip_h = true
	elif global_position.x < face_to.x:
		sprite.flip_h = false
	

func attack(attack_pos) -> void:
	face_sprite(Navigation.get_world_coords(attack_pos))
	sprite.play("attack")
	await sprite.animation_finished
	sprite.play("idle")


func update_hero() -> void:
	if not is_inside_tree():
		await ready
		
	sprite.sprite_frames = stats.frames
	sprite.play("idle")
	update_stats()


func update_stats() -> void:
	stats_ui.update_stats(stats)


func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	stats.take_damage(damage)
	
	if stats.health <= 0:
		queue_free()
