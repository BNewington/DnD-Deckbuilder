class_name UnitStats
extends Resource

signal stats_changed

@export var name: String
@export var frames: SpriteFrames
@export var max_health: int

var health: int : set = set_health


func set_health(value: int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()
