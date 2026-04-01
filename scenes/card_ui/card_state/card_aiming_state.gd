extends CardState

const MOUSE_Y_CANCEL_THRESHOLD := 550

var area: Array[Vector2i]
var valid_targets: Array[Vector2i]
var num_actions: int
var current_area: int

var previously_selected_tile: Vector2i

var menu_mode: bool = false

func _ready() -> void:
	Events.menu_opened.connect(func(): menu_mode = true)
	Events.menu_closed.connect(func(): menu_mode = false)

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
			if action is TileAction:
				area = card_ui.card.get_area(current_area)
				if action.requires_aiming():
					valid_targets = card_ui.card.get_valid_targets(current_area)
					Events.card_aiming_ended.emit(card_ui)
					Events.card_aiming_started.emit(card_ui,area,valid_targets)
					break
				else:
					card_ui.card.execute_tile_effects(action.effects,area)
					if i == num_actions:
						transition_requested.emit(self, State.RELEASED)
			elif action is CardAction:
				card_ui.card.execute_card_effects(action.effects)
				if i == num_actions:
						transition_requested.emit(self, State.RELEASED)


func on_input(event: InputEvent) -> void:
	if menu_mode: return
	var mouse_pos = Navigation.find_3d_mouse_pos()
	var selected_tile = Navigation.get_tile_coords(mouse_pos)
	var mouse_over_area: bool = selected_tile in valid_targets
	
	if current_area < num_actions and mouse_over_area:
		var next_action = card_ui.card.actions[current_area+1]
		if next_action.is_aoe() and previously_selected_tile != selected_tile:
			var next_aoe = card_ui.card.get_area_for_highlight(current_area+1, selected_tile)
			Events.update_aoe_highlights.emit(next_aoe)
	
	if event.is_action_pressed("right_mouse"):
		if not card_ui.card.can_cancel_after(current_area):
			transition_requested.emit(self, State.RELEASED)
		transition_requested.emit(self, State.BASE)
	
	elif mouse_over_area:
		Events.show_tile_selector.emit()
		if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
			card_ui.targets.append(selected_tile)
			if current_area == num_actions:
				print(selected_tile)
				aiming_selected(selected_tile)
				transition_requested.emit(self, State.RELEASED)
			else:
				aiming_selected(selected_tile)
			
	else:
		Events.hide_tile_selector.emit()
		var a: Array[Vector2i] = []
		Events.update_aoe_highlights.emit(a)
	
	previously_selected_tile = selected_tile
