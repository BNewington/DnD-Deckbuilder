extends CardState


func enter() -> void:
	#HACK for displaying state logic
	card_ui.color.color = Color.ORANGE
	card_ui.state.text = "CLICKED"
	
	card_ui.card_area.monitoring = true
	card_ui.drag_point = card_ui.get_global_mouse_position() - card_ui.global_position

func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		transition_requested.emit(self, State.DRAGGING)
