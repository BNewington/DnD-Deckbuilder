class_name StatsUI
extends Control

@onready var health_label: Label = %HealthLabel
@onready var v_box_container: VBoxContainer = $VBoxContainer


func update_stats(stats: UnitStats) -> void:
	health_label.text = str(stats.health)
	health_label.visible = stats.health > 0


func add_status_handler(status_handler: StatusHandler) -> void:
	v_box_container.add_child(status_handler)
