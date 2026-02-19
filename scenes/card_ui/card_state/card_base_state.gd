extends CardState


func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready
	
	if card_ui.get_parent() is not Hand:
		card_ui.reparent_requested.emit(card_ui)
	
	card_ui.z_index = card_ui.hand_z_index
	card_ui.target_rotation = card_ui.hand_rotation
	card_ui.target_pos = card_ui.hand_pos
	card_ui.color.color = Color.WEB_GREEN
	card_ui.state.text = "BASE"


func mouse_entered() -> void:
	if card_ui.position == card_ui.target_pos:
		transition_requested.emit(self, State.HOVERED)


func hover_stopped() -> void:
	if card_ui.mouse_over:
		transition_requested.emit(self, State.HOVERED)
