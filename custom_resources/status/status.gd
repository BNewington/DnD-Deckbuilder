class_name Status
extends Resource

signal status_applied(status: Status)
signal status_changed

enum Type {START_OF_TURN, END_OF_TURN, EVENT_BASED}
enum StackType {NONE, INTENSITY, DURATION}

@export_group("Data")
@export var id: String
@export var type: Type
@export var stack_type: StackType
@export var can_expire: bool
@export var modifier: Modifier.Type
@export var modifier_type: ModifierValue.Type

@export_subgroup("Percentile Modifier")
@export var percentile_value: float

@export_group("Visuals")
@export var icon: Texture
@export_multiline var tooltip: String

var duration: int = 1 : set = set_duration
var stacks: int = 1 : set = set_stacks


func init_status(target: Unit) -> void:
	status_changed.connect(_on_status_changed.bind(target))
	_on_status_changed(target)


func apply_status(_target: Unit) -> void:
	status_applied.emit(self)


func get_tooltip() -> String:
	return tooltip


func set_duration(new_duration: int) -> void:
	duration = new_duration
	status_changed.emit()


func set_stacks(new_stacks: int) -> void:
	stacks = new_stacks
	status_changed.emit()


func _on_status_changed(target: Node) -> void:
	var modifier_node: Modifier = target.modifier_handler.get_modifier(modifier)
	assert(modifier_node, "No matching modifier found on %s" % target)
	var existing_modifier_value := modifier_node.get_value(id)
	
	if not existing_modifier_value:
		existing_modifier_value = ModifierValue.create_new_modifier(id, modifier_type)
	
	match modifier_type:
		ModifierValue.Type.PERCENTILE:
			existing_modifier_value.percentile_value = percentile_value
		ModifierValue.Type.ADDITIVE:
			existing_modifier_value.additive_value = stacks
	
	modifier_node.add_new_value(existing_modifier_value)
