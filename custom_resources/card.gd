class_name Card
extends Resource

enum Type {ATTACK, SKILL, POWER}
enum Target {SELF, SQUARE, AREA}
enum Hero {Warrior, Thief, Mage}


@export_group("Card Attributes")
@export var id: String
@export var type: Type
@export var target: Target


func does_target_square() -> bool:
	return target == Target.SQUARE


func does_target_area() -> bool:
	return target == Target.AREA


func does_target_self() -> bool:
	return target == Target.SELF


func get_area(hero_pos) -> Array[Vector2i]:
	return []
