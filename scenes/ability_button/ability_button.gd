class_name AbilityButton
extends Button

var area: Array[Vector2i]
var valid_targets: Array[Vector2i]
var num_actions: int
var current_area: int

var previously_selected_tile: Vector2i

var menu_mode: bool = false

var active: bool = false

@export var card: Card
@export var unit: Unit


func _ready() -> void:
	Events.menu_opened.connect(func(): menu_mode = true)
	Events.menu_closed.connect(func(): menu_mode = false)
	Events.start_turn.connect(_on_turn_started)


func _on_turn_started(unit: Unit) -> void:
	if disabled:
		disabled = false


func enter() -> void:
	active = true
	current_area = 0
	num_actions = card.actions.size()-1
	
	card.unit = unit
	area = card.get_area(current_area)
	valid_targets = card.get_valid_targets(current_area)
	Events.card_aiming_started.emit(area,valid_targets)
	Events.cursor_mode_hand.emit()
	


func exit() -> void:
	active = false
	Events.card_aiming_ended.emit()
	Events.cursor_mode_pointer.emit()
	Events.hide_tile_selector.emit()
	card.selected_tiles = []


func aiming_selected(selected_tile: Vector2i) -> void:
	card.area_selected(current_area,selected_tile)
	current_area += 1
	if current_area <= num_actions:
		for i in range(current_area,num_actions+1):
			var action = card.actions[i]
			if action is TileAction:
				area = card.get_area(current_area)
				if action.requires_aiming():
					valid_targets = card.get_valid_targets(current_area)
					Events.card_aiming_ended.emit()
					Events.card_aiming_started.emit(area,valid_targets)
					break
				else:
					card.execute_tile_effects(action, action.effects,area)
					if i == num_actions:
						exit()
			elif action is CardAction:
				card.execute_card_effects(action.effects)
				if i == num_actions:
						exit()


func _input(event: InputEvent) -> void:
	if menu_mode: return
	if not active: return
	var mouse_pos = Navigation.find_3d_mouse_pos()
	var selected_tile = Navigation.get_tile_coords(mouse_pos)
	var mouse_over_area: bool = selected_tile in valid_targets
	
	if current_area < num_actions and mouse_over_area:
		#TODO fix aoe highlighting to work with aoe effect
		var next_action = card.actions[current_area+1]
		if next_action.is_aoe() and previously_selected_tile != selected_tile:
			var next_aoe = card.get_area_for_highlight(current_area+1, selected_tile)
			Events.update_aoe_highlights.emit(next_aoe)
	
	if event.is_action_pressed("right_mouse"):
		if not card.can_cancel_after(current_area):
			disabled = true
		exit()
	
	elif mouse_over_area:
		Events.show_tile_selector.emit()
		if event.is_action_pressed("left_mouse"):
			if current_area == num_actions:
				aiming_selected(selected_tile)
				exit()
				disabled = true
			else:
				aiming_selected(selected_tile)
			
	else:
		Events.hide_tile_selector.emit()
		var a: Array[Vector2i] = []
		Events.update_aoe_highlights.emit(a)
	
	previously_selected_tile = selected_tile


func _on_pressed() -> void:
	if active:
		exit()
	else:
		enter()
