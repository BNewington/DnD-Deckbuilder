class_name UnitStats
extends Resource

signal stats_changed

@export var name: String
@export var model: PackedScene
@export var max_health: int

var health: int : set = set_health
var block: int : set = set_block


func set_health(value: int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()


func set_block(value: int) -> void:
	block = clampi(value, 0, 999)
	stats_changed.emit()


func take_damage(damage: int) -> void:
	if damage > block:
		block = 0
		health -= damage-block
	else:
		block -= damage


func heal(amount: int) -> void:
	health += amount


func create_instance() -> UnitStats:
	var instance: UnitStats = self.duplicate()
	instance.health = max_health
	return instance
