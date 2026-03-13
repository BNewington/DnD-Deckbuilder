class_name TurnManager
extends Node3D

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var hand: Hand
@onready var heroes: Array[Node] = $Heroes.get_children()
@onready var enemies: Array[Node] = $Enemies.get_children()

var initiative: Array[Node] = []
var current_unit: Unit


func _ready() -> void:
	Events.turn_ended.connect(end_turn)
	Events.hand_discarded.connect(start_next_turn)
	Events.unit_died.connect(_on_unit_died)
	Events.draw_card.connect(draw_card)


func start_battle() -> void:
	for hero: Unit in heroes:
		var hero_stats: HeroStats = hero.stats
		hero_stats.draw_pile = hero_stats.deck.duplicate(true)
		hero_stats.draw_pile.shuffle()
		hero_stats.discard = CardPile.new()
		hero.add_to_group("heroes")
		
	for enemy: Unit in enemies:
		enemy.add_to_group("enemies")
	
	initiative = heroes + enemies
	
	start_turn(initiative[0])


func start_turn(unit: Unit) -> void:
	current_unit = unit
	Events.start_turn.emit(unit)
	print("emitted")
	
	if unit.stats is HeroStats:
		unit.stats.reset_energy()
		draw_cards(unit.stats)
	elif unit.stats is EnemyStats:
		unit.start_turn()


func end_turn(unit: Unit) -> void:
	current_unit.end_turn()
	if unit.stats is HeroStats:
		hand.disable_hand()
		discard_cards()
	elif unit.stats is EnemyStats:
		start_next_turn(unit)


func draw_card(hero_stats: HeroStats) -> void:
	reshuffle_deck_from_discard()
	hand.add_card(hero_stats.draw_pile.draw_card())
	reshuffle_deck_from_discard()


func draw_cards(hero_stats: HeroStats) -> void:
	var amount: int = hero_stats.cards_per_turn
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card.bind(hero_stats))
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(func():
		Events.hand_drawn.emit()
		current_unit.start_turn())


func discard_cards() -> void:
	var tween := create_tween()
	var stats: HeroStats = current_unit.stats
	for card_ui in hand.cards:
		tween.tween_callback(stats.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	tween.finished.connect(
		func():
			Events.hand_discarded.emit(current_unit)
	)


func reshuffle_deck_from_discard() -> void:
	var stats: HeroStats = current_unit.stats
	if not stats.draw_pile.empty():
		return
	
	while not stats.discard.empty():
		stats.draw_pile.add_card(stats.discard.draw_card())
	
	stats.draw_pile.shuffle()


func start_next_turn(unit: Unit) -> void:
	var current_unit_index = initiative.find(unit)
	if current_unit_index >= initiative.size()-1:
		current_unit_index = 0
	else:
		current_unit_index += 1
	
	start_turn(initiative[current_unit_index])


func _on_unit_died(unit: Unit) -> void:
	initiative.erase(unit)
	if unit.stats is EnemyStats:
		enemies.erase(unit)
	elif unit.stats is HeroStats:
		heroes.erase(unit)
