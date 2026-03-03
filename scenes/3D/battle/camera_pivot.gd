extends Node3D

@export var move_speed: float = 4.0

@export_range(0, 50) var orbit_speed: float = 4.0
var _target_orbit := rotation.y

@export var circular_radius: float = 0.0
@export var circular_speed: float = 0.2

var is_panning = false
var input_vec: Vector2

@onready var cam: Camera3D = $Camera3D


func _process(delta: float) -> void:
	if Input.is_action_pressed("cam_pan"):
		is_panning = true
	else:
		is_panning = false
	if not is_panning:
		input_vec = Input.get_vector("cam_left", "cam_right", "cam_back", "cam_forward")
	# basis without pitch, so pretty much the yaw; who rolls a camera??
	var yaw := Basis(basis.x, Vector3.UP, basis.z).orthonormalized()
	# scaling forward so pitched ortho camera speed seems constant as if 2D
	var move_vec := yaw * Vector3(input_vec.x, 0, input_vec.y / sin(rotation.x))
	if is_panning:
		position += move_vec * delta
	else:
		position += move_vec * move_speed * delta
	# orbit
	if Input.is_action_just_pressed("cam_orbit_right"):
		_target_orbit += TAU/8
	if Input.is_action_just_pressed("cam_orbit_left"):
		_target_orbit -= TAU/8
	rotation.y = lerpf(rotation.y, _target_orbit, 1.0 - 2.0 ** (-4.0 * delta * orbit_speed))
	if absf(rotation.y - _target_orbit) < 0.02:
		rotation.y = _target_orbit


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_panning:
		var dist = event.screen_relative
		input_vec = Vector2(-dist.x,dist.y)
