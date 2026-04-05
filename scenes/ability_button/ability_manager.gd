class_name AbilityManager
extends Control

const ABILITY_BUTTON_CONTAINER = preload("uid://cqxcegot31kry")

func _ready() -> void:
	Events.start_turn.connect(_on_turn_started)
	Events.turn_ended.connect(_on_turn_ended)
	Events.start_battle.connect(_on_battle_started)


func _on_turn_started(unit: Unit) -> void:
	for container: AbilityButtonContainer in get_children():
		if container.hero == unit:
			container.show()


func _on_turn_ended(unit: Unit) -> void:
	for container: AbilityButtonContainer in get_children():
		if container.hero == unit:
			container.hide()


func _on_battle_started() -> void:
	var heroes: Array[Node] = Navigation.get_units(Navigation.UnitType.Hero)
	for hero in heroes:
		var new_container: AbilityButtonContainer = ABILITY_BUTTON_CONTAINER.instantiate()
		add_child(new_container)
		new_container.hero = hero
