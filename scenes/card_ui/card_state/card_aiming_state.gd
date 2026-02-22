extends CardState

const MOUSE_Y_CANCEL_THRESHOLD := 550

var area: Array[Vector2i]

func enter() -> void:
	card_ui.animate_to_position(card_ui.hand.global_position - Vector2(0,40), 0.2)
	card_ui.targets.clear()
	
	var hero_pos = Navigation.get_tile_coords(card_ui.belongs_to.global_position)
	area = card_ui.card.get_area()
	Events.card_aiming_started.emit(card_ui,area)
	Events.cursor_mode_hand.emit()
	


func exit() -> void:
	Events.card_aiming_ended.emit(card_ui)
	Events.cursor_mode_pointer.emit()
	Events.hide_tile_selector.emit()


#TODO make this a little more readable
func on_input(event: InputEvent) -> void:
	var selected_tile = Navigation.get_tile_coords(card_ui.get_global_mouse_position())
	var mouse_over_area: bool = selected_tile in area
	
	if event.is_action_pressed("right_mouse"):
		transition_requested.emit(self, State.BASE)
	
	elif mouse_over_area:
		Events.show_tile_selector.emit()
		if event.is_action_pressed("left_mouse"):
			card_ui.targets.append(selected_tile)
			transition_requested.emit(self, State.RELEASED)
	else:
		Events.hide_tile_selector.emit()
