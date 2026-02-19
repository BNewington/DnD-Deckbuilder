class_name CardState
extends Node

enum State {
	BASE,
	HOVERED,
	CLICKED,
	DRAGGING,
	AIMING,
	RELEASED
}

signal transition_requested(from: CardState, to: State)

@export var state: State

var card_ui: CardUI
var state_machine: CardStateMachine


func enter() -> void:
	pass


func exit() -> void:
	pass


func on_input(_event: InputEvent) -> void:
	pass


func mouse_entered() -> void:
	pass


func mouse_exited() -> void:
	pass


func on_card_hovered(_card: CardUI) -> void:
	pass


func hover_stopped() -> void:
	pass
