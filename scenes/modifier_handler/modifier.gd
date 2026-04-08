class_name Modifier
extends Node

enum Type {DMG_DEALT, DMG_TAKEN, CARD_COST, SHOP_COST, MOVE_AMOUNT, NO_MODIFIER}

@export var type: Type


func get_value(source: String) -> ModifierValue:
	for value: ModifierValue in get_children():
		if value.source == source:
			return value
	return null


func add_new_value(value: ModifierValue) -> void:
	var modifier_value := get_value(value.source)
	if not modifier_value:
		add_child(value)
	else:
		modifier_value.additive_value = value.additive_value
		modifier_value.percentile_value = value.percentile_value


func remove_value(source: String) -> void:
	for value: ModifierValue in get_children():
		if value.source == source:
			value.queue_free()


func clear_values() -> void:
	for value: ModifierValue in get_children():
		value.queue_free()


func get_modified_value(base: int) -> int:
	var additive_result: int = base
	var percentile_result: float = 1.0
	
	for value: ModifierValue in get_children():
		if value.type == ModifierValue.Type.ADDITIVE:
			additive_result += value.additive_value
		elif value.type == ModifierValue.Type.PERCENTILE:
			percentile_result += value.percentile_value
	
	return floori(additive_result * percentile_result)
