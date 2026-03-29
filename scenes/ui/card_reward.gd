class_name CardReward
extends Control

signal card_selected(card: Card)

const CARD_MENU_UI_SCENE = preload("uid://cjowue6xxofne")

@export var rewards: Array[Card] : set = set_rewards

@onready var skip_button: Button = %SkipButton
@onready var card_container: HBoxContainer = %CardContainer


func _ready() -> void:
	skip_button.pressed.connect(hide)
	for card_ui: CardMenuUI in card_container.get_children():
		card_ui.inspect_requested.connect(_on_card_selected)


func set_rewards(value: Array[Card]) -> void:
	rewards = value
	
	if not is_node_ready():
		await ready
		
	var i = 0
	for card_ui: CardMenuUI in card_container.get_children():
		card_ui.card = rewards[i]
		i+=1


func _on_card_selected(card: Card) -> void:
	card_selected.emit(card)
	hide()
