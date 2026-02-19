class_name CardUI
extends Node2D

signal reparent_requested(which_card_ui: CardUI)

const MOVE_SPEED: float = 8000.0
const ROTATE_SPEED: float = 5.0

@onready var color: ColorRect = $Color/Color2
@onready var state: Label = $Color/Label
@onready var card_state_machine: CardStateMachine = $CardStateMachine
@onready var card_area: Area2D = $CardArea
@onready var targets: Array[Node] = []

var drag_point: Vector2
var mouse_over: bool
var hand: Hand

var hand_z_index: int = 0
var hand_rotation: float
var hand_pos: Vector2
var target_rotation: float
var target_pos: Vector2

var test_rot = 0.0


func _ready() -> void:
	card_state_machine.init(self)


func _process(delta: float) -> void:
	if card_state_machine.current_state.state != card_state_machine.current_state.State.DRAGGING:
		position = position.move_toward(target_pos, MOVE_SPEED * delta)
		
	rotation = rotate_toward(rotation,deg_to_rad(target_rotation),ROTATE_SPEED*delta)


func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)


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
