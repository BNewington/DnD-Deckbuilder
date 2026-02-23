class_name BattleUI
extends CanvasLayer

@export var unit: Unit : set = set_unit

@onready var hand: Hand = $Hand
@onready var energy_ui: EnergyUI = $EnergyUI
@onready var end_turn_button: Button = %EndTurnButton


func _ready() -> void:
	print(hand)
	Events.start_turn.connect(turn_started)
	Events.hand_drawn.connect(_on_hand_drawn)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)


func set_unit(value: Unit) -> void:
	if not is_node_ready():
		await ready
	
	unit = value
	hand.unit = unit
	
	if unit.stats is HeroStats:
		energy_ui.hero_stats = unit.stats


func turn_started(current_unit: Unit) -> void:
	unit = current_unit


func _on_hand_drawn() -> void:
	end_turn_button.disabled = false


func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	Events.hero_turn_ended.emit()
