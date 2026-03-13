class_name Card
extends Resource

enum Type {ATTACK, SKILL, POWER}
enum Hero {Warrior, Thief, Mage}

var unit: Unit

@export_group("Card Attributes")
@export var id: String
@export var name: String
@export var type: Type
@export var cost: int

@export var actions: Array[Action]

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var description: String

var last_selected_tile: Vector2i
var selected_tiles: Array[Vector2i] = []


func does_target_square() -> bool:
	for action in actions:
		if action.requires_aiming():
			return true
	return false


func get_area(action_id: int) -> Array[Vector2i]:
	var area: AreaDef = actions[action_id].target
	if actions[action_id].player_performed:
		return area.get_area(unit.grid_pos)
	else:
		var tile_action_id = actions[action_id].performer_action_id
		return area.get_area(selected_tiles[tile_action_id])


func get_area_for_highlight(action_id: int, temp_pos: Vector2i) -> Array[Vector2i]:
	var area: AreaDef = actions[action_id].target
	if actions[action_id].player_performed:
		return area.get_area(unit.grid_pos)
	else:
		return area.get_area(temp_pos)

func get_valid_targets(action_id: int) -> Array[Vector2i]:
	var area = get_area(action_id)
	return actions[action_id].target.get_valid_target_cells(area)


func play() -> void:
	if not does_target_square():
		var i = 0
		for action in actions:
			if action is CardAction:
				execute_card_effects(action.effects)
			elif action is TileAction:
				execute_tile_effects(action.effects,get_area(i))
			i += 1
	Events.card_played.emit(self)
	unit.stats.energy -= cost
	unit.stats.discard.add_card(self)
	selected_tiles = []


func area_selected(action_id: int, tile: Vector2i) -> void:
	var tile_array: Array[Vector2i] = [tile]
	last_selected_tile = tile
	selected_tiles.append(tile)
	var action = actions[action_id]
	var effects = action.effects
	execute_tile_effects(effects,tile_array)
	execute(action_id, tile_array)
	Events.effect_resolved.emit()


func execute_tile_effects(effects: Array[TileEffect], tiles: Array[Vector2i]) -> void:
	for effect in effects:
		if effect.executor == TileEffect.ExecutorType.SELF:
			effect.execute(unit,tiles)
		elif effect.executor == TileEffect.ExecutorType.PREVIOUSLY_SELECTED_UNIT:
			print(selected_tiles[effect.executor_id])
			var previously_selected_unit = Navigation.get_unit_at_tile(selected_tiles[effect.executor_id])
			effect.execute(previously_selected_unit,tiles)


func execute_card_effects(effects: Array[CardEffect]) -> void:
	for effect in effects:
		effect.execute(unit)


func can_cancel_after(action_id: int) -> bool:
	for action in actions.slice(0,action_id):
		if not action.can_cancel_after:
			return false
	return true

func execute(area_id: int, targets: Array) -> void:
	print("executed effect at target(s): %s"%targets)
