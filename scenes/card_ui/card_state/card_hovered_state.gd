extends CardState


func enter() -> void:
	card_ui.z_index = 11
	card_ui.target_rotation = 0
	card_ui.target_pos.y = -100
	card_ui.scale = Vector2.ONE * 1.1
	Events.card_hovered.emit(card_ui)


func exit() -> void:
	card_ui.scale = Vector2.ONE


func mouse_exited() -> void:
	Events.hover_stopped.emit()
	transition_requested.emit(self, State.BASE)


func on_input(event: InputEvent) -> void:
	if not card_ui.playable or card_ui.disabled:
		return
	if event.is_action_pressed("left_mouse"):
		transition_requested.emit(self, State.CLICKED)


func on_card_hovered(card: CardUI) -> void:
	if card != self:
		transition_requested.emit(self, State.BASE)
