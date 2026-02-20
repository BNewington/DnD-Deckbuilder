extends CardState


const DRAG_MINIMUM_THRESHOLD: float = 0.05

var minimum_drag_time_elapsed: bool = false

func enter() -> void:
	#HACK for displaying state logic
	card_ui.color.color = Color.NAVY_BLUE
	card_ui.state.text = "DRAGGING"
	
	card_ui.remove_from_hand()
	card_ui.target_rotation = 0.0
	
	minimum_drag_time_elapsed = false
	var threshold_timer := get_tree().create_timer(DRAG_MINIMUM_THRESHOLD,false)
	threshold_timer.timeout.connect(func(): minimum_drag_time_elapsed = true)
	
	Events.card_dragging_started.emit(card_ui)


func exit() -> void:
	Events.card_dragging_ended.emit(card_ui)


func on_input(event: InputEvent) -> void:
	var targets_square: bool = card_ui.card.does_target_square()
	var mouse_motion: bool = event is InputEventMouseMotion
	var cancel: bool = event.is_action_pressed("right_mouse")
	var confirm: bool = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	
	if targets_square and mouse_motion and card_ui.targets.size() > 0:
		transition_requested.emit(self, State.AIMING)
	
	if mouse_motion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.drag_point
	
	if cancel:
		transition_requested.emit(self, State.BASE)
	elif minimum_drag_time_elapsed and confirm:
		get_viewport().set_input_as_handled()
		transition_requested.emit(self, State.RELEASED)
