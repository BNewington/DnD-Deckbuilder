class_name BattleUI
extends CanvasLayer

@export var current_unit: Unit : set = set_unit

@onready var hand: Hand = $Hand
@onready var energy_ui: EnergyUI = $EnergyUI
@onready var end_turn_button: TextureButton = %EndTurnButton
@onready var stats_ui: Control = $StatsUI
@onready var initiative_ui: HBoxContainer = $InitiativeUI

const STATS_UI = preload("uid://d0tnkfen53ayh")
const UNIT_INITITATIVE = preload("uid://d283xg7ma5kaq")
const STATUS_HANDLER = preload("uid://ceigyvtjnqkr8")


var current_hovered_unit: Unit
var unit_stats: Dictionary = {} #Key is unit, value is [stats, initiative_tracker]

var frame_times = []

func _ready() -> void:
	Events.start_turn.connect(turn_started)
	Events.hand_drawn.connect(_on_hand_drawn)
	Events.card_aiming_started.connect(_on_card_aiming_started)
	Events.card_aiming_ended.connect(_on_card_aiming_ended)
	Events.set_stats.connect(_on_stats_set)
	Events.unit_hovered.connect(mouse_over_unit)
	Events.unit_hovered_off.connect(mouse_off_unit)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	for unit in unit_stats.keys():
		unit_stats[unit][0].hide()


func _process(delta: float) -> void:
	frame_times.append(1/delta)
	if frame_times.size() > 60:
		var sum = 0
		for frame in frame_times:
			sum += frame
		$Label.text = str(int(sum/60))
		frame_times = []
	
	for unit in unit_stats.keys():
		if is_instance_valid(unit):
			var stats = unit_stats[unit][0]
			var ui_offset = Vector2(stats.size.x/2,0)
			stats.global_position = Navigation.find_2d_screen_pos(unit.tool_tip_pos) - ui_offset
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
	var unit = current_unit
	Events.turn_ended.emit(unit)


func _on_card_aiming_started(_area: Array[Vector2i], _valid_targets: Array[Vector2i]) -> void:
	end_turn_button.disabled = true


func _on_card_aiming_ended() -> void:
	end_turn_button.disabled = false


func sort_initiative(initiative: Array[Node]) -> void:
	for unit in unit_stats.keys():
		var initiative_tracker = unit_stats[unit][1]
		initiative_ui.move_child(initiative_tracker, initiative.find(unit))


func _on_stats_set(unit: Unit, stats: UnitStats) -> void:
	var stats_ui_instance = STATS_UI.instantiate()
	if not stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.connect(_on_stats_changed)
	stats_ui.add_child(stats_ui_instance)
	if not stats_ui_instance.is_node_ready():
		await stats_ui_instance.ready
	
	var new_status_handler = STATUS_HANDLER.instantiate()
	new_status_handler.status_owner = unit
	stats_ui_instance.add_status_handler(new_status_handler)
	unit.status_handler = new_status_handler
	
	stats_ui_instance.update_stats(stats)
	
	var unit_initiative_instance = UNIT_INITITATIVE.instantiate() as UnitInitiative
	initiative_ui.add_child(unit_initiative_instance)
	if not unit_initiative_instance.is_node_ready():
		await unit_initiative_instance.ready
		
	unit_initiative_instance.mouse_over.connect(mouse_over)
	unit_initiative_instance.mouse_off.connect(mouse_off)
	unit_initiative_instance.name_text = stats.name
	unit_initiative_instance.max_health = stats.max_health
	unit_initiative_instance.health = stats.health
	
	
	unit_stats[unit] = [stats_ui_instance,unit_initiative_instance]


func mouse_over(unit_initiative: UnitInitiative) -> void:
	for unit in unit_stats.keys():
		if unit_initiative in unit_stats[unit]:
			Events.unit_hovered.emit(unit)
			break


func mouse_off(unit_initiative: UnitInitiative) -> void:
	current_hovered_unit = null
	for unit in unit_stats.keys():
		if unit_initiative in unit_stats[unit]:
			Events.unit_hovered_off.emit(unit)
			break


func mouse_over_unit(hovered_unit: Unit) -> void:
	current_hovered_unit = hovered_unit
	if Input.is_action_pressed("show_stats"): return
	for unit in unit_stats.keys():
		if unit == hovered_unit:
			unit_stats[unit][0].show()
		else:
			unit_stats[unit][0].hide()


func mouse_off_unit(hovered_unit: Unit) -> void:
	if Input.is_action_pressed("show_stats"): return
	for unit in unit_stats.keys():
		if unit == hovered_unit:
			unit_stats[unit][0].hide()


func _on_stats_changed() -> void:
	for unit in unit_stats.keys():
		var stats = unit_stats[unit][0]
		var initiative_tracker = unit_stats[unit][1]
		stats.update_stats(unit.stats)
		initiative_tracker.health = unit.stats.health


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_stats"):
		for unit in unit_stats.keys():
			unit_stats[unit][0].show()
	elif event.is_action_released("show_stats"):
		for unit in unit_stats.keys():
			if unit != current_hovered_unit:
				unit_stats[unit][0].hide()
