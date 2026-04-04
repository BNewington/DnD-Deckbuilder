class_name Hand
extends Node2D


const MAX_WIDTH: float = 650.0
const MAX_CARDS: int = 10
const HAND_HEIGHT: float = 35.0
const MAX_ROTATION: float = 15.0

@onready var cards: Array[Node] = get_children() : get = get_cards
@onready var hand_size = float(len(cards)) : get = get_hand_size
@onready var card_ui := preload("uid://oxhrvfr17p53")

@export var unit: Unit
@export_group("Display Curves")
@export var height_curve: Curve
@export var fan_curve: Curve

var cards_played_this_turn: int = 0

func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	Events.turn_ended.connect(_on_turn_ended)
	arrange_hand()


func get_cards() -> Array[Node]:
	return get_children()


func get_hand_size() -> float:
	return float(len(cards))


func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	var new_index: int = child.original_index - cards_played_this_turn
	new_index = clampi(new_index, 0, get_child_count())
	move_child(child, new_index)
	arrange_hand()


func add_card(card: Card) -> void:
	var new_card_ui: CardUI = card_ui.instantiate()
	add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.hand = self
	new_card_ui.unit = unit
	
	arrange_hand()


func discard_card(card: CardUI) -> void:
	card.queue_free()


func disable_hand() -> void:
	for card in cards:
		card.disabled = true


func arrange_hand() -> void:
	cards = get_children()
	hand_size = float(len(cards))
	
	if hand_size == 0:
		return
	
	if hand_size == 1:
		var card: CardUI = cards[0]
		card.hand = self
		card.hand_pos = Vector2.ZERO
		card.hand_rotation = 0
		return
	
	
	var hand_size_ratio = (hand_size/MAX_CARDS)
	for card_id in range(hand_size):
		var index = card_id/(hand_size-1)
		var card: CardUI = cards[card_id]
		
		card.hand = self
		card.hand_z_index = int(index*10)
		
		var horizontal_position = ((2*index)-1)
		card.hand_pos.x = horizontal_position * MAX_WIDTH * hand_size_ratio
		
		var height = height_curve.sample(index)
		card.hand_pos.y = height * HAND_HEIGHT * hand_size_ratio * -1
		
		var angle = (fan_curve.sample(index))
		card.hand_rotation = angle * MAX_ROTATION * hand_size_ratio


func _on_card_played(_card: Card) -> void:
	cards_played_this_turn += 1


func _on_turn_ended(_hero: Unit) -> void:
	cards_played_this_turn = 0
