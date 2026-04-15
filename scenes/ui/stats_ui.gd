class_name StatsUI
extends Control

@onready var health_label: Label = %HealthLabel
@onready var v_box_container: VBoxContainer = $PanelContainer/VBoxContainer
@onready var block_label: Label = %BlockLabel
@onready var block_container: HBoxContainer = %BlockContainer


func update_stats(stats: UnitStats) -> void:
	health_label.text = str(stats.health) + "/" + str(stats.max_health)
	health_label.visible = stats.health > 0
	block_label.text = str(stats.block)
	block_container.visible = stats.block > 0


func add_status_handler(status_handler: StatusHandler) -> void:
	v_box_container.add_child(status_handler)
