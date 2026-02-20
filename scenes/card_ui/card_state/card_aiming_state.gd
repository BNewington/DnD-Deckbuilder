extends CardState

const MOUSE_Y_CANCEL_THRESHOLD := 550

var area: Array[Vector2i]

func enter() -> void:
	card_ui.color.color = Color.WEB_PURPLE
	card_ui.state.text = "AIMING"
	
	card_ui.animate_to_position(card_ui.hand.global_position - Vector2(0,20), 0.2)
	card_ui.targets.clear()
	
	var hero_pos = Navigation.get_tile_coords(card_ui.belongs_to.global_position)
	area = card_ui.card.get_area(hero_pos)
	Events.card_aiming_started.emit(card_ui,area)
	Events.cursor_mode_hand.emit()
	


func exit() -> void:
	Events.card_aiming_ended.emit(card_ui)
	Events.cursor_mode_pointer.emit()
	Events.hide_tile_selector.emit()


func on_input(event: InputEvent) -> void:
	var mouse_motion: bool = event is InputEventMouseMotion
	var mouse_at_bottom: bool = card_ui.get_global_mouse_position().y > MOUSE_Y_CANCEL_THRESHOLD
	var mouse_over_area: bool = Navigation.get_tile_coords(card_ui.get_global_mouse_position()) in area
	
	if event.is_action_pressed("right_mouse"):
		transition_requested.emit(self, State.BASE)
	elif mouse_over_area:
		Events.show_tile_selector.emit()
	else:
		Events.hide_tile_selector.emit()
