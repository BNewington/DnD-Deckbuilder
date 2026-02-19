class_name Unit
extends Area2D

@export var stats: HeroStats : set = set_stats

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	Events.start_battle.connect(start_battle)

func start_battle() -> void:
	global_position = Navigation.snap_to_grid(global_position)

func set_stats(value: HeroStats) -> void:
	stats = value
	
	if not stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.connect(_on_stats_changed)
	
	update_hero()


func update_hero() -> void:
	if not is_inside_tree():
		await ready
		
	sprite.sprite_frames = stats.frames
	sprite.play("idle")


func _on_stats_changed() -> void:
	pass
