class_name CardUI
extends Node2D

signal reparent_requested(which_card_ui: CardUI)

const MOVE_SPEED: float = 8000.0
const ROTATE_SPEED: float = 5.0

@export var card: Card : set = set_card
@export var unit: Unit : set = set_unit


@onready var name_label: Label = $Panel/Name
@onready var energy_cost: Label = $Panel/EnergyCost
@onready var icon: TextureRect = $Panel/Icon
@onready var description: RichTextLabel = $Panel/Description


@onready var card_state_machine: CardStateMachine = $CardStateMachine
@onready var card_area: Area2D = $CardArea
@onready var targets: Array = []

var drag_point: Vector2
var mouse_over: bool
var hand: Hand
var tween: Tween

var hand_z_index: int = 0 : set = set_hand_z_index
var hand_rotation: float : set = set_hand_rotation
var hand_pos: Vector2 : set = set_hand_pos
var target_rotation: float
var target_pos: Vector2

var playable: bool = true : set = set_playable
var disabled: bool = false


func _ready() -> void:
	card_state_machine.init(self)
	#card.belongs_to = belongs_to


func set_unit(value: Unit) -> void:
	unit = value
	if unit.stats is HeroStats:
		unit.stats.stats_changed.connect(_on_stats_changed)


func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	name_label.text = card.name
	energy_cost.text = str(card.cost)
	icon.texture = card.icon
	description.text = card.description


func set_hand_z_index(value: int) -> void:
	hand_z_index = value
	z_index = value


func set_hand_rotation(value: float) -> void:
	hand_rotation = value
	target_rotation = value


func set_hand_pos(value: Vector2) -> void:
	hand_pos = value
	target_pos = value


func set_playable(value: bool ) -> void:
	playable = value
	if not playable:
		energy_cost.modulate = Color(0.988, 0.0, 0.0, 0.62)
		name_label.modulate = Color(0.0, 0.0, 0.0, 0.5)
		description.modulate = Color(0.0, 0.0, 0.0, 0.5)
		icon.modulate = Color(0.0, 0.0, 0.0, 0.5)
	else:
		energy_cost.modulate = Color(1.0, 1.0, 1.0, 1.0)
		name_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		description.modulate = Color(1.0, 1.0, 1.0, 1.0)
		icon.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _process(delta: float) -> void:
	#HACK - should use the animate_to_position function
	var is_base: bool = card_state_machine.current_state.state == CardState.State.BASE
	var is_hovered: bool = card_state_machine.current_state.state == CardState.State.HOVERED
	if is_base or is_hovered:
		position = position.move_toward(target_pos, MOVE_SPEED * delta)
	rotation = rotate_toward(rotation,deg_to_rad(target_rotation),ROTATE_SPEED*delta)


func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)


func _on_stats_changed() -> void:
	if not card:
		return
	var stats: HeroStats = unit.stats
	playable = stats.can_play_card(card)


func _on_card_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mouse"):
		mouse_over = true
		card_state_machine.mouse_entered()
	
	elif area.is_in_group("card_drop_area"):
		if not targets.has(area):
			targets.append(area)


func _on_card_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("mouse"):
		mouse_over = false
		card_state_machine.mouse_exited()
	
	elif area.is_in_group("card_drop_area"):
		targets.erase(area)


func remove_from_hand() -> void:
	var ui_layer = get_tree().get_first_node_in_group("ui_layer")
	reparent(ui_layer)
	hand.arrange_hand()


func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"global_position",new_position,duration)


func play() -> void:
	card.play(targets)
	queue_free()
