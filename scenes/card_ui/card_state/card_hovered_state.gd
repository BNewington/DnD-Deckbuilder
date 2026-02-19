extends CardState


func enter() -> void:
	card_ui.color.color = Color.DARK_MAGENTA
	card_ui.state.text = "HOVERED"
	card_ui.z_index = 11
	card_ui.target_rotation = 0
	card_ui.target_pos.y -= 10
	Events.card_hovered.emit(card_ui)


func mouse_exited() -> void:
	Events.hover_stopped.emit()
	transition_requested.emit(self, State.BASE)


func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		transition_requested.emit(self, State.CLICKED)


func on_card_hovered(card: CardUI) -> void:
	if card != self:
		transition_requested.emit(self, State.BASE)
