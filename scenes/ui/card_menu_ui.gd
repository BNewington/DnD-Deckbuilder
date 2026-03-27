class_name CardMenuUI
extends CenterContainer

signal inspect_requested(card: Card)

@export var card: Card : set = set_card

@onready var name_label: Label = $Visuals/Sprite/Name
@onready var energy_cost: Label = $Visuals/Sprite/EnergyCost
@onready var icon: TextureRect = $Visuals/Sprite/Icon
@onready var description: RichTextLabel = $Visuals/Sprite/Description


func _on_sprite_mouse_entered() -> void:
	pass # TODO make hover effect


func _on_sprite_mouse_exited() -> void:
	pass # Replace with function body.


func _on_sprite_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		inspect_requested.emit(card)


func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	name_label.text = card.name
	icon.texture = card.icon
	energy_cost.text = str(card.cost)
	description.text = card.description
