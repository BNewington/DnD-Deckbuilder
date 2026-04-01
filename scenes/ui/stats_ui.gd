class_name StatsUI
extends Control

@onready var health_label: Label = %HealthLabel


func update_stats(stats: UnitStats) -> void:
	health_label.text = str(stats.health)
	health_label.visible = stats.health > 0
