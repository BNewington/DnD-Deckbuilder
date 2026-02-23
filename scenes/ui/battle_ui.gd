class_name BattleUI
extends CanvasLayer

@export var unit: Unit : set = set_unit

@onready var hand: Hand = $Hand
@onready var energy_ui: EnergyUI = $EnergyUI


func _ready() -> void:
	Events.start_turn.connect(turn_started)


func set_unit(value: Unit) -> void:
	unit = value
	hand.unit = unit
	
	if unit.stats is HeroStats:
		energy_ui.hero_stats = unit.stats


func turn_started(current_unit: Unit) -> void:
	unit = current_unit
