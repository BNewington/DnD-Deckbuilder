class_name Unit
extends Area2D

@export var stats: HeroStats : set = set_stats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var tween: Tween
var grid_pos: Vector2i : get = get_grid_pos


func _ready() -> void:
	Events.start_battle.connect(start_battle)

func start_battle() -> void:
	global_position = Navigation.snap_to_grid(global_position)

func set_stats(value: HeroStats) -> void:
	stats = value
	
	if not stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.connect(_on_stats_changed)
	
	update_hero()


func get_grid_pos() -> Vector2i:
	return Navigation.get_tile_coords(global_position)


func move_to(target: Vector2i) -> void:
	var path = Navigation.get_cell_path(Navigation.get_tile_coords(global_position),target)
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if path:
		for tile in path:
			var next_pos = Navigation.get_world_coords(tile)
			tween.tween_property(self, "global_position",next_pos,0.15)


func update_hero() -> void:
	if not is_inside_tree():
		await ready
		
	sprite.sprite_frames = stats.frames
	sprite.play("idle")


func _on_stats_changed() -> void:
	pass
