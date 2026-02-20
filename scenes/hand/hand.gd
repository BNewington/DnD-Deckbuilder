class_name Hand
extends Node2D


const MAX_WIDTH: float = 350.0
const MAX_CARDS: int = 10
const HAND_HEIGHT: float = 35.0
const MAX_ROTATION: float = 15.0
@onready var cards: Array[Node] = get_children()
@onready var hand_size = float(len(cards))

@export var height_curve: Curve
@export var fan_curve: Curve


func _ready() -> void:
	for child in get_children():
		var card_ui: CardUI = child
		card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
		
	arrange_hand()


func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	arrange_hand()


func add_card(card: CardUI) -> bool:
	if hand_size < MAX_CARDS:
		add_child(card)
		arrange_hand()
		return true
	else:
		return false


func arrange_hand() -> void:
	cards = get_children()
	hand_size = float(len(cards))
	
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
