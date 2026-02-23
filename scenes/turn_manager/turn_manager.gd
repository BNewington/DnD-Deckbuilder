class_name TurnManager
extends Node2D

const HAND_DRAW_INTERVAL := 0.25

@export var hand: Hand
@onready var heroes: Array[Node] = $Heroes.get_children()

var current_unit: Unit


func start_battle() -> void:
	for hero: Unit in heroes:
		var hero_stats: HeroStats = hero.stats
		hero_stats.draw_pile = hero_stats.deck.duplicate(true)
		hero_stats.draw_pile.shuffle()
		hero_stats.discard = CardPile.new()
		
	start_turn(heroes[0])


func start_turn(unit: Unit) -> void:
	current_unit = unit
	Events.start_turn.emit(unit)
	
	if unit.stats is HeroStats:
		unit.stats.reset_energy()
		draw_cards(unit.stats)


func draw_card(hero_stats: HeroStats) -> void:
	hand.add_card(hero_stats.draw_pile.draw_card())


func draw_cards(hero_stats: HeroStats) -> void:
	var amount: int = hero_stats.cards_per_turn
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card.bind(hero_stats))
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(func():
		Events.hand_drawn.emit()
		current_unit.start_turn())
