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

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var description: String


func does_target_square() -> bool:
	return target == Target.SQUARE


func does_target_area() -> bool:
	return target == Target.AREA


func does_target_self() -> bool:
	return target == Target.SELF


func get_area() -> Array[Vector2i]:
	return []



func play(targets: Array) -> void:
	Events.card_played.emit(self)
	unit.stats.energy -= cost
	execute(targets)


func execute(targets: Array) -> void:
	print("executed effect at target(s): %s"%targets)
