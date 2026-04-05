class_name AbilityButtonContainer
extends VBoxContainer


var hero: Unit : set = set_hero

const ABILITY_BUTTON = preload("uid://dqmu1hb34x71m")


func set_hero(value: Unit) -> void:
	hero = value
	for button in get_children():
		button.queue_free()
		
	var hero_stats: HeroStats = hero.stats
	for ability in hero_stats.abilities:
		var new_button: AbilityButton = ABILITY_BUTTON.instantiate()
		add_child(new_button)
		new_button.text = ability.name
		new_button.unit = hero
		new_button.card = ability
