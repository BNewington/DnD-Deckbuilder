class_name HeroUI
extends CanvasLayer

var current_hero_turn: Unit

const CARD_PILE_VIEW_SCENE = preload("uid://dilpax6jng0j4")

@onready var draw_pile_button: CardPileButton = %DrawPileButton
@onready var discard_pile_button: CardPileButton = %DiscardPileButton
@onready var draw: Control = $CardPileViews/Draw
@onready var discard: Control = $CardPileViews/Discard

func _ready() -> void:
	Events.start_turn.connect(_on_turn_started)
	draw_pile_button.pressed.connect(draw_pile_button_pressed)
	discard_pile_button.pressed.connect(discard_pile_button_pressed)


func setup_card_pile_views() -> void:
	var heroes = Navigation.get_units(Navigation.UnitType.Hero)
	for hero in heroes:
		var new_draw_pile := CARD_PILE_VIEW_SCENE.instantiate() as CardPileView
		var new_discard_pile := CARD_PILE_VIEW_SCENE.instantiate() as CardPileView
		var stats: HeroStats = hero.stats
		new_discard_pile.hero = hero
		new_draw_pile.hero = hero
		new_discard_pile.card_pile = stats.discard
		new_draw_pile.card_pile = stats.draw_pile
		draw.add_child(new_draw_pile)
		discard.add_child(new_discard_pile)


func _on_turn_started(unit: Unit) -> void:
	if unit.stats is HeroStats:
		var stats: HeroStats = unit.stats
		current_hero_turn = unit
		draw_pile_button.card_pile = stats.draw_pile
		discard_pile_button.card_pile = stats.discard


func draw_pile_button_pressed() -> void:
	for draw_pile: CardPileView in draw.get_children():
		if draw_pile.hero == current_hero_turn:
			draw_pile.show_current_view(current_hero_turn.stats.name + " Draw Pile", true)
	pass


func discard_pile_button_pressed() -> void:
	for discard_pile: CardPileView in discard.get_children():
		if discard_pile.hero == current_hero_turn:
			discard_pile.show_current_view(current_hero_turn.stats.name + " Discard Pile")
	pass
