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

@export var target_selectors: Array[AreaDef]

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var description: String

var last_selected_tile: Vector2i
var selected_tiles: Array[Vector2i] = []


func does_target_square() -> bool:
	for target_selector in target_selectors:
		if target_selector.requires_aiming():
			return true
	return false


func get_area(area_id: int) -> Array[Vector2i]:
	var area: AreaDef = target_selectors[area_id]
	match area.origin_type:
		AreaDef.OriginType.UNIT:
			return area.get_area(unit.grid_pos)
		AreaDef.OriginType.LAST_SELECTED_TILE:
			return area.get_area(last_selected_tile)
		_:
			return []


func get_valid_targets(area_id: int) -> Array[Vector2i]:
	var area = get_area(area_id)
	return target_selectors[area_id].get_valid_target_cells(area)


func play() -> void:
	Events.card_played.emit(self)
	unit.stats.energy -= cost
	unit.stats.discard.add_card(self)


func area_selected(area_id: int, tile: Vector2i) -> void:
	last_selected_tile = tile
	selected_tiles.append(tile)
	print(selected_tiles)
	var effects = target_selectors[area_id].effects
	for effect in effects:
		if effect.executor == Effect.ExecutorType.SELF:
			effect.execute(unit,[tile])
		elif effect.executor == Effect.ExecutorType.PREVIOUSLY_SELECTED_UNIT:
			print(selected_tiles[effect.executor_id])
			var previously_selected_unit = Navigation.get_unit_at_tile(selected_tiles[effect.executor_id])
			effect.execute(previously_selected_unit,[tile])
	execute(area_id, [tile])


func execute(area_id: int, targets: Array) -> void:
	print("executed effect at target(s): %s"%targets)
