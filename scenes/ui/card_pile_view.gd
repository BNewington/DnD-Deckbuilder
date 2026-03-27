class_name CardPileView
extends Control

const CARD_MENU_UI_SCENE = preload("uid://cjowue6xxofne")

@export var card_pile: CardPile

@onready var title: Label = %Title
@onready var cards: GridContainer = %Cards
@onready var card_inspect: CardInspect = %CardInspect
@onready var back_button: Button = %BackButton

var hero: Unit

func _ready() -> void:
	back_button.pressed.connect(hide)
	
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_inspect.hide_card()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_inspect.visible:
			card_inspect.hide_card()
		else:
			hide()


func show_current_view(new_title: String, randomized: bool = false) -> void:
	for card: Node in cards.get_children():
		card.queue_free()
	card_inspect.hide_card()
	title.text = new_title
	_update_view.call_deferred(randomized)


func _update_view(randomized: bool) -> void:
	if not card_pile:
		return
	print(card_pile.cards)
	var all_cards := card_pile.cards.duplicate()
	if randomized:
		all_cards.shuffle()
	
	for card: Card in all_cards:
		var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
		new_card.card = card
		cards.add_child(new_card)
		new_card.inspect_requested.connect(card_inspect.show_card)
	
	show()
