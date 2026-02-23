class_name EnergyUI
extends Panel

@onready var label: Label = $Label

var hero_stats: HeroStats : set = set_stats


func set_stats(value: HeroStats) -> void:
	hero_stats = value
	
	if not hero_stats.stats_changed.is_connected(_on_stats_changed):
		hero_stats.stats_changed.connect(_on_stats_changed)
	
	
	if not is_node_ready():
		await ready


func _on_stats_changed() -> void:
	label.text = "%s/%s"%[hero_stats.energy,hero_stats.max_energy]
