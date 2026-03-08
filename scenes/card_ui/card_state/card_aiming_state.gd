extends CardState

const MOUSE_Y_CANCEL_THRESHOLD := 550

var area: Array[Vector2i]
var valid_targets: Array[Vector2i]
var num_actions: int
var current_area: int


func enter() -> void:
	current_area = 0
	num_actions = card_ui.card.actions.size()-1
	card_ui.animate_to_position(card_ui.hand.global_position - Vector2(0,40), 0.2)
	card_ui.targets.clear()
	
	area = card_ui.card.get_area(current_area)
	valid_targets = card_ui.card.get_valid_targets(current_area)
	Events.card_aiming_started.emit(card_ui,area,valid_targets)
	Events.cursor_mode_hand.emit()
	


func exit() -> void:
	Events.card_aiming_ended.emit(card_ui)
	Events.cursor_mode_pointer.emit()
	Events.hide_tile_selector.emit()
	card_ui.card.selected_tiles = []


func aiming_selected(selected_tile: Vector2i) -> void:
	card_ui.card.area_selected(current_area,selected_tile)
	current_area += 1
	if current_area <= num_actions:
		for i in range(current_area,num_actions+1):
			var action = card_ui.card.actions[i]
			area = card_ui.card.get_area(current_area)
			if action.requires_aiming():
				valid_targets = card_ui.card.get_valid_targets(current_area)
				Events.card_aiming_ended.emit(card_ui)
				Events.card_aiming_started.emit(card_ui,area,valid_targets)
				break
			else:
				card_ui.card.execute_effects(action.effects,area)
				if i == num_actions:
					transition_requested.emit(self, State.RELEASED)


func on_input(event: InputEvent) -> void:
	var mouse_pos = Navigation.find_3d_mouse_pos()
	var selected_tile = Navigation.get_tile_coords(mouse_pos)
	var mouse_over_area: bool = selected_tile in valid_targets
	
	if event.is_action_pressed("right_mouse"):
		if not card_ui.card.can_cancel_after(current_area):
			transition_requested.emit(self, State.RELEASED)
		transition_requested.emit(self, State.BASE)
	
	elif mouse_over_area:
		Events.show_tile_selector.emit()
		if event.is_action_pressed("left_mouse"):
			card_ui.targets.append(selected_tile)
			if current_area == num_actions:
				print(selected_tile)
				aiming_selected(selected_tile)
				transition_requested.emit(self, State.RELEASED)
			else:
				aiming_selected(selected_tile)
			
	else:
		Events.hide_tile_selector.emit()
