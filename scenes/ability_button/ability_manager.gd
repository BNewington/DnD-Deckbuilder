class_name AbilityManager
extends Control

const ABILITY_BUTTON_CONTAINER = preload("uid://cqxcegot31kry")

func _ready() -> void:
	Events.start_turn.connect(_on_turn_started)
	Events.turn_ended.connect(_on_turn_ended)


func _on_turn_started(unit: Unit) -> void:
	if get_child_count() == 0:
		await Events.start_battle
	
	for container: AbilityButtonContainer in get_children():
		if container.hero == unit:
			container.show()
		else:
			container.hide()


func _on_turn_ended(unit: Unit) -> void:
	for container: AbilityButtonContainer in get_children():
		if container.hero == unit:
			container.hide()


func setup_ability_buttons() -> void:
	var heroes: Array[Node] = Navigation.get_units(Navigation.UnitType.Hero)
	for hero in heroes:
		var new_container: AbilityButtonContainer = ABILITY_BUTTON_CONTAINER.instantiate()
		add_child(new_container)
		new_container.hero = hero
