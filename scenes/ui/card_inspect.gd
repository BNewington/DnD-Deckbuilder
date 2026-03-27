class_name CardInspect
extends Control

const CARD_MENU_UI_SCENE = preload("uid://cjowue6xxofne")

@onready var card_art: CenterContainer = $VBoxContainer/CardArt


func _ready() -> void:
	for card: CardMenuUI in card_art.get_children():
		card.queue_free()


func show_card(card: Card) -> void:
	var new_card = CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	card_art.add_child(new_card)
	new_card.card = card
	new_card.inspect_requested.connect(hide_card.unbind(1))
	show()


func hide_card() -> void:
	if not visible: return
	
	for card: CardMenuUI in card_art.get_children():
		card.queue_free()
	
	hide()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_card()
