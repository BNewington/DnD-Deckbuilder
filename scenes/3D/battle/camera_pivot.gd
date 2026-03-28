extends Node3D

@export var move_speed: float = 12.0
@export var focus_speed: float = 0.2

@export_range(0, 50) var orbit_speed: float = 4.0
var _target_orbit := rotation.y

@export var circular_radius: float = 0.0
@export var circular_speed: float = 0.2

var is_panning = false
var input_vec: Vector2
var current_unit: Unit
var target_pos: Vector3 : set = set_target_pos
var is_focusing: bool = false
var focus_offset: float = 2

var menu_mode: bool = false

@onready var cam: Camera3D = $Camera3D


func _ready() -> void:
	Events.start_turn.connect(_on_turn_started)
	
	Events.menu_opened.connect(func(): menu_mode = true)
	Events.menu_closed.connect(func(): menu_mode = false)


func _process(delta: float) -> void:
	focus_target()
	if is_focusing or menu_mode:
		return
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
		pass
	else:
		position += move_vec * move_speed * delta
	# orbit
	if Input.is_action_just_pressed("cam_orbit_right"):
		_target_orbit += TAU/8
	if Input.is_action_just_pressed("cam_orbit_left"):
		_target_orbit -= TAU/8
	
	
	if absf(rotation.y - _target_orbit) < 0.02:
		rotation.y = _target_orbit
	else:
		rotation.y = lerp_angle(rotation.y, _target_orbit, 1.0 - 2.0 ** (-4.0 * delta * orbit_speed))
	
	if Input.is_action_just_pressed("cam_center"):
		target_pos = current_unit.global_position - (Vector3.UP * focus_offset)
	


func _input(event: InputEvent) -> void:
	if menu_mode: return
	if event is InputEventMouseMotion and is_panning:
		var dist = event.screen_relative
		input_vec = Vector2(-dist.x,dist.y) / 80
		var yaw := Basis(basis.x, Vector3.UP, basis.z).orthonormalized()
		# scaling forward so pitched ortho camera speed seems constant as if 2D
		var move_vec := yaw * Vector3(input_vec.x, 0, input_vec.y / sin(rotation.x))
		position += move_vec


func _on_turn_started(unit: Unit) -> void:
	current_unit = unit
	target_pos = unit.global_position - (Vector3.UP * focus_offset)


func set_target_pos(value: Vector3) -> void:
	target_pos = value
	is_focusing = true


func focus_target() -> void:
	var focus_threshold = 0.5
	if is_focusing:
		global_position = global_position.lerp(target_pos,focus_speed)
		if (global_position-target_pos).length() < focus_threshold:
			global_position = target_pos
			is_focusing = false
