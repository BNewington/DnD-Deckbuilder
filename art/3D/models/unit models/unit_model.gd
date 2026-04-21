extends Node3D

signal animation_finished(animation: String)

@export var black_outline: MeshInstance3D
@export var white_outline: MeshInstance3D
@export var animation_player: AnimationPlayer
@onready var tooltip_pos_node: Marker3D = $TooltipPos

var tooltip_pos: Vector3 : get = get_tooltip_pos
var unit: Unit


func _ready() -> void:
	Events.unit_hovered.connect(_on_unit_hovered)
	Events.unit_hovered_off.connect(_on_unit_hovered_off)
	if animation_player:
		animation_player.animation_finished.connect(on_animation_finished)


func get_tooltip_pos() -> Vector3:
	return tooltip_pos_node.global_position


func _on_unit_hovered(hovered_unit: Unit) -> void:
	if not (black_outline or white_outline): return
	if hovered_unit == unit:
		black_outline.hide()
		white_outline.show()


func _on_unit_hovered_off(hovered_unit: Unit) -> void:
	if not (black_outline or white_outline): return
	if hovered_unit == unit:
		black_outline.show()
		white_outline.hide()


func play_animation(animation: String) -> void:
	if animation_player:
			animation_player.stop()
			animation_player.play("Library/"+animation)



func on_animation_finished(animation: String) -> void:
	animation_finished.emit(animation)
