class_name Card
extends Resource

enum Type {ATTACK, SKILL, POWER}
enum Target {SELF, SQUARE, AREA}
enum Hero {Warrior, Thief, Mage}

var unit: Unit

@export_group("Card Attributes")
@export var id: String
@export var name: String
@export var type: Type
@export var target: Target
@export var cost: int

@export var target_selectors: Array[AreaDef]

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var description: String

var last_selected_tile: Vector2i


func does_target_square() -> bool:
	return target == Target.SQUARE


func does_target_area() -> bool:
	return target == Target.AREA


func does_target_self() -> bool:
	return target == Target.SELF


func get_area(area_id: int) -> Array[Vector2i]:
	var area: AreaDef = target_selectors[area_id]
	match area.origin_type:
		AreaDef.OriginType.UNIT:
			return area.get_area(unit.grid_pos)
		AreaDef.OriginType.LAST_SELECTED_TILE:
			return area.get_area(last_selected_tile)
		_:
			return []


func play() -> void:
	Events.card_played.emit(self)
	unit.stats.energy -= cost
	unit.stats.discard.add_card(self)


func area_selected(area_id: int, tile: Vector2i) -> void:
	last_selected_tile = tile
	execute(area_id, [tile])


func execute(area_id: int, targets: Array) -> void:
	print("executed effect at target(s): %s"%targets)
