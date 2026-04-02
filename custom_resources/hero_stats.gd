class_name HeroStats
extends UnitStats

enum HeroType {Warrior, Thief, Mage}

@export var type: HeroType
@export var starting_deck: CardPile
@export var cards_per_turn: int
@export var max_energy: int
@export var draftable_cards: CardPile

var energy: int : set = set_energy
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile


func set_energy(value: int) -> void:
	energy = clamp(value, 0, 999)
	stats_changed.emit()


func reset_energy() -> void:
	energy = max_energy


func can_play_card(card: Card) -> bool:
	return energy >= card.cost


func create_instance() -> HeroStats:
	var instance: HeroStats = self.duplicate()
	instance.health = max_health
	instance.reset_energy()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
