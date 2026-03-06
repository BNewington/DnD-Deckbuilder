class_name BattleUI
extends CanvasLayer

@export var current_unit: Unit : set = set_unit

@onready var hand: Hand = $Hand
@onready var energy_ui: EnergyUI = $EnergyUI
@onready var end_turn_button: Button = %EndTurnButton
@onready var stats_ui: Control = $StatsUI

const STATS_UI = preload("uid://d0tnkfen53ayh")


var unit_stats: Dictionary = {}


func _ready() -> void:
	Events.start_turn.connect(turn_started)
	Events.hand_drawn.connect(_on_hand_drawn)
	Events.card_aiming_started.connect(_on_card_aiming_started)
	Events.card_aiming_ended.connect(_on_card_aiming_ended)
	Events.set_stats.connect(_on_stats_set)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)


func _process(_delta: float) -> void:
	for unit in unit_stats.keys():
		if is_instance_valid(unit):
			var stats = unit_stats[unit]
			var ui_offset = Vector2(stats.size.x/2,0)
			stats.global_position = Navigation.find_2d_screen_pos(unit.global_position) - ui_offset
		else:
			unit_stats[unit].queue_free()
			unit_stats.erase(unit)


func set_unit(value: Unit) -> void:
	if not is_node_ready():
		await ready
	
	current_unit = value
	hand.unit = current_unit
	
	if current_unit.stats is HeroStats:
		energy_ui.hero_stats = current_unit.stats


func turn_started(unit: Unit) -> void:
	end_turn_button.disabled = true
	current_unit = unit


func _on_hand_drawn() -> void:
	end_turn_button.disabled = false


func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	Events.turn_ended.emit(current_unit)


func _on_card_aiming_started(_card_ui: CardUI, _area: Array[Vector2i], _valid_targets: Array[Vector2i]) -> void:
	end_turn_button.disabled = true


func _on_card_aiming_ended(_card_ui: CardUI) -> void:
	end_turn_button.disabled = false


func _on_stats_set(unit: Unit, stats: UnitStats) -> void:
	var stats_ui_instance = STATS_UI.instantiate()
	stats.stats_changed.connect(_on_stats_changed)
	stats_ui.add_child(stats_ui_instance)
	stats_ui_instance.update_stats(stats)
	unit_stats[unit] = stats_ui_instance


func _on_stats_changed() -> void:
	for unit in unit_stats.keys():
		var stats = unit_stats[unit]
		stats.update_stats(unit.stats)
