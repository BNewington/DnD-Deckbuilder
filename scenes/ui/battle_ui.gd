class_name BattleUI
extends CanvasLayer

@export var current_unit: Unit : set = set_unit

@onready var hand: Hand = $Hand
@onready var energy_ui: EnergyUI = $EnergyUI
@onready var end_turn_button: TextureButton = %EndTurnButton
@onready var stats_ui: Control = $StatsUI
@onready var initiative_ui: VBoxContainer = $InitiativeUI

const STATS_UI = preload("uid://d0tnkfen53ayh")
const UNIT_INITITATIVE = preload("uid://d283xg7ma5kaq")


var hovered_initiative: UnitInitiative
var unit_stats: Dictionary = {}


func _ready() -> void:
	Events.start_turn.connect(turn_started)
	Events.hand_drawn.connect(_on_hand_drawn)
	Events.card_aiming_started.connect(_on_card_aiming_started)
	Events.card_aiming_ended.connect(_on_card_aiming_ended)
	Events.set_stats.connect(_on_stats_set)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)


func _process(_delta: float) -> void:
	$Label.text = str(int(1/_delta))
	for unit in unit_stats.keys():
		if is_instance_valid(unit):
			var stats = unit_stats[unit][0]
			var ui_offset = Vector2(stats.size.x/2,0)
			stats.global_position = Navigation.find_2d_screen_pos(unit.global_position) - ui_offset
		else:
			unit_stats[unit][0].queue_free()
			unit_stats[unit][1].queue_free()
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
	
	var unit_initiative_instance = UNIT_INITITATIVE.instantiate() as UnitInitiative
	initiative_ui.add_child(unit_initiative_instance)
	unit_initiative_instance.mouse_over.connect(mouse_over)
	unit_initiative_instance.mouse_off.connect(mouse_off)
	unit_initiative_instance.name_text = stats.name
	unit_initiative_instance.max_health = stats.max_health
	unit_initiative_instance.health = stats.health
	
	
	unit_stats[unit] = [stats_ui_instance,unit_initiative_instance]


func mouse_over(unit_initiative: UnitInitiative) -> void:
	for unit in unit_stats.keys():
		if unit_initiative in unit_stats[unit]:
			Events.initiative_hovered.emit(unit)
			break


func mouse_off(unit_initiative: UnitInitiative) -> void:
	for unit in unit_stats.keys():
		if unit_initiative in unit_stats[unit]:
			Events.initiative_hovered_off.emit(unit)
			break


func _on_stats_changed() -> void:
	for unit in unit_stats.keys():
		var stats = unit_stats[unit][0]
		var initiative_tracker = unit_stats[unit][1]
		stats.update_stats(unit.stats)
		initiative_tracker.health = unit.stats.health
