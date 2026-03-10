class_name UnitInitiative
extends Control

@onready var name_label: Label = $TextureRect/NameLabel
@onready var health_label: Label = $HealthLabel


var name_text: String = "" : set = set_name_label
var health: int = 0 : set = set_health
var max_health: int = 0


func set_name_label(value: String) -> void:
	name_text = value
	name_label.text = value


func set_health(value: int) -> void:
	health = value
	health_label.text = "%s/%s" % [health,max_health]
