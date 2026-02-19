class_name CardStateMachine
extends Node

@export var initial_state: CardState

var current_state: CardState
var states := {}


func init(card: CardUI) -> void:
	Events.card_hovered.connect(on_card_hovered)
	Events.hover_stopped.connect(hover_stopped)
	
	for child in get_children():
		if child is CardState:
			states[child.state] = child
			child.transition_requested.connect(on_transition_requested)
			child.card_ui = card
		
	if initial_state:
		initial_state.enter()
		current_state = initial_state


func on_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_input(event)


func mouse_entered() -> void:
	if current_state:
		current_state.mouse_entered()


func mouse_exited() -> void:
	if current_state:
		current_state.mouse_exited()


func on_card_hovered(card: CardUI) -> void:
	if current_state:
		current_state.on_card_hovered(card)


func hover_stopped() -> void:
	if current_state:
		current_state.hover_stopped()


func on_transition_requested(from: CardState, to: CardState.State) -> void:
	if from != current_state:
		return
	
	var new_state: CardState = states[to]
	if not new_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
