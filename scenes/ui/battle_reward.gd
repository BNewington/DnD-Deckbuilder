class_name BattleReward
extends Control

enum RewardType {WARRIOR_CARD, MAGE_CARD, GOLD}

@export var rewards: Array[RewardType]
@onready var buttons: VBoxContainer = $VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer
@onready var card_reward: CardReward = $CardReward

var current_card_button: Button
var char_stats: HeroStats

func _ready() -> void:
	Events.reward_collected.connect(_on_reward_collected)
	card_reward.card_selected.connect(_on_card_selected)


func init_rewards(unit: Unit) -> void:
	char_stats = unit.stats
	generate_card_rewards(unit.stats)
	var gold = randi_range(10,20)
	var gold_button = add_button(str(gold)+" gold")
	var card_button = add_button(unit.stats.name+" card")
	
	gold_button.pressed.connect(_on_gold_selected.bind(gold,gold_button))
	card_button.pressed.connect(_on_card_reward_selected.bind(card_button))


func add_button(text: String) -> Button:
	var new_button = Button.new()
	new_button.text = text
	buttons.add_child(new_button)
	new_button.custom_minimum_size.y = 80
	new_button.set("theme_override_font_sizes/font_size", 60)
	return new_button


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		close()


func close() -> void:
	hide()
	Events.menu_closed.emit()


func _on_reward_collected(unit: Unit) -> void:
	init_rewards(unit)
	show()
	Events.menu_opened.emit()


#TODO add weighted randomness for card rarity
func _on_card_reward_selected(button: Button) -> void:
	current_card_button = button
	card_reward.show()


func generate_card_rewards(hero_stats: HeroStats) -> void:
	var cards: Array[Card] = []
	var avaliable_cards: Array[Card] = hero_stats.draftable_cards.cards.duplicate(true)
	for i in range(3):
		var rand = randi_range(0, avaliable_cards.size()-1)
		cards.append(avaliable_cards[rand])
		avaliable_cards.remove_at(rand)
	card_reward.rewards = cards


func _on_gold_selected(amount: int, button: Button) -> void:
	print("gained ",amount," gold")
	button.queue_free()


func _on_card_selected(card: Card) -> void:
	current_card_button.queue_free()
	char_stats.draw_pile.insert_card(0,card)
	char_stats.deck.add_card(card)
	Events.card_reward_confirmed.emit(card)
