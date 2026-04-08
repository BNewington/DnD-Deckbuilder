class_name ModifierValue
extends Node

enum Type {PERCENTILE, ADDITIVE}

@export var type: Type
@export var percentile_value: float
@export var additive_value: int
@export var source: String


static func create_new_modifier(modifier_source: String, modifier_type: Type) -> ModifierValue:
	var new_modifier := new()
	new_modifier.source = modifier_source
	new_modifier.type = modifier_type
	
	return new_modifier
