extends Node3D

signal animation_finished(animation: String)

@export var outline: MeshInstance3D
@export var animation_player: AnimationPlayer


func _ready() -> void:
	if animation_player:
		animation_player.animation_finished.connect(on_animation_finished)


func hide_outline() -> void:
	outline.hide()


func show_outline() -> void:
	outline.show()


func play_animation(animation: String) -> void:
	if animation_player:
		animation_player.play(animation)



func on_animation_finished(animation: String) -> void:
	animation_finished.emit(animation)
