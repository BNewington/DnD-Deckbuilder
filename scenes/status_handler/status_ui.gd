class_name StatusUI
extends Control

@export var status: Status : set = set_status

@onready var icon: TextureRect = $Icon
@onready var duration_label: Label = $DurationLabel
@onready var stacks_label: Label = $StacksLabel


func set_status(new_status: Status) -> void:
	if not is_node_ready():
		await ready
	
	status = new_status
	icon.texture = status.icon
	duration_label.visible = status.stack_type == Status.StackType.DURATION
	stacks_label.visible = status.stack_type == Status.StackType.INTENSITY
	
	if not status.status_changed.is_connected(_on_status_changed):
		status.status_changed.connect(_on_status_changed)
	
	_on_status_changed()


func _on_status_changed() -> void:
	if not status:
		return
	
	if status.can_expire and status.duration <= 0:
		queue_free()
	
	if status.stack_type == Status.StackType.INTENSITY and status.stacks == 0:
		queue_free()
	
	duration_label.text = str(status.duration)
	stacks_label.text = str(status.stacks)
