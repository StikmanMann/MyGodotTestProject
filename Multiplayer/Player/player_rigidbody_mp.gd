# PlayerRBMP.gd
class_name PlayerRBMP
extends RigidBody3D

@export var player_id := 1:
	set(id): 
		player_id = id 
		%InputSynchroniser.set_multiplayer_authority(id)

@onready var camera: Camera3D          = $BoundingBox/RotationHelper/Camera3D
@onready var rotation_helper: Node3D   = $BoundingBox/RotationHelper
@onready var bounding_box: Node3D      = $BoundingBox
@onready var input_sync: Node           = %InputSynchroniser
@onready var pickup_mp: PickupMP = $BoundingBox/RotationHelper/Pickup_MP
@onready var interact_mp: InteractorMP = $BoundingBox/RotationHelper/Interact_MP

# ---- Tuning ----
const MAX_SPEED        := 10.0
const ACCELERATION     := MAX_SPEED * 10.0
const MAX_AIR_SPEED    := 1.0
const AIR_ACCELERATION := MAX_SPEED * 20.0
const FRICTION         := 16.0
const JUMP_VELOCITY    := 5.0
const MOUSE_SENS       := 0.001       # radians per pixel
const PITCH_LIMIT_deg  := 70.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_on_floor: bool = false
var attempt_pickup: bool =false
var attempt_interact: bool =false

signal change_mouse_mode



func _ready() -> void:
	# Camera only for the local owner
	if multiplayer.get_unique_id() == player_id:
		camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# Optional: lighten remote players (no camera)
		pass

	change_mouse_mode.connect(_change_mouse_mode)

# ---------- CAMERA LOOK ----------
func _apply_look(delta_vec: Vector2) -> void:
	# delta_vec.x = mouse X, delta_vec.y = mouse Y
	# Yaw on body, pitch on camera helper
	var yaw   := -delta_vec.x * MOUSE_SENS
	var pitch := -delta_vec.y * MOUSE_SENS

	bounding_box.rotate_y(yaw)

	rotation_helper.rotate_x(pitch)
	# Clamp pitch
	var rot := rotation_helper.rotation_degrees
	rot.x = clamp(rot.x, -PITCH_LIMIT_deg, PITCH_LIMIT_deg)
	rotation_helper.rotation_degrees = rot
	
	# -------- Camera POS ------ LOCLA ONLY! :D

func _input(event):
	if event is InputEventKey: 
		print(event.as_text_keycode())
		if event.as_text_keycode() == "T": 
			camera.transform = $BoundingBox/ThirdPerson.transform 
		elif event.as_text_keycode() == "F": 
			camera.transform = $BoundingBox/FirstPerson.transform

# ---------- MOVEMENT ----------
func _apply_movement(move_input: Vector2, delta: float) -> void:
	# move_input.y = forward/back, move_input.x = right/left (same mapping as you used)
	var wish_dir: Vector3 = Vector3(move_input.x, 0.0, move_input.y)
	wish_dir = wish_dir.rotated(Vector3.UP, bounding_box.rotation.y).normalized()

	var current_speed := linear_velocity.dot(wish_dir)

	if not is_on_floor or input_sync.jumping:
		# gravity & air control
		linear_velocity.y -= gravity * delta
		var add_speed := clamp(MAX_AIR_SPEED - current_speed, 0.0, AIR_ACCELERATION * delta) as float
		linear_velocity += wish_dir * add_speed
	else:
		# ground friction & accel
		linear_velocity.x = lerp(linear_velocity.x, 0.0, delta * FRICTION)
		linear_velocity.z = lerp(linear_velocity.z, 0.0, delta * FRICTION)
		var add_speed := clamp(MAX_SPEED - current_speed, 0.0, ACCELERATION * delta) as float
		linear_velocity += wish_dir * add_speed

	# Jump (server checks; local can predict too if you want)
	if input_sync.jumping and is_on_floor:
		linear_velocity.y = JUMP_VELOCITY

# ---------- FLOOR CHECK ----------
@onready var floor_checks: Node3D = $BoundingBox/FloorChecks
const SLOPE_LIMIT_DOT := cos(deg_to_rad(45.0))

func _is_on_floor() -> bool:
	for d in floor_checks.get_children():
		for ray: RayCast3D in d.get_children():
			if ray.is_colliding():
				var n := ray.get_collision_normal()
				if n.dot(Vector3.UP) >= SLOPE_LIMIT_DOT:
					return true
	return false

# ---------- INPUT MOUSE TOGGLE ----------
func _change_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# ---------- TICKS ----------
func _process(_delta: float) -> void:
	if multiplayer.is_server():
		_apply_look(input_sync.look_delta)
		input_sync.look_delta = Vector2.ZERO# don't zero here -> let server consume it too

func _physics_process(delta: float) -> void:
	# Server runs the authoritative simulation
	if multiplayer.is_server():
		is_on_floor = _is_on_floor()
		_apply_look(input_sync.look_delta)
		# Server has consumed this frame's mouse input -> clear it to prevent drift
		#input_sync.look_delta = Vector2.ZERO
		_apply_movement(input_sync.movement_input, delta)
		if attempt_pickup:
			print("attempt pickup: %s" % attempt_pickup) 
			attempt_pickup = false
			pickup_mp.pickup()
			
		if attempt_interact:
			print("attempt interact: %s" % attempt_interact)
			attempt_interact = false
			interact_mp._interact()

	# Optional client-side prediction. Uncomment if you want even snappier movement:
	# elif multiplayer.get_unique_id() == player_id:
	#     is_on_floor = _is_on_floor()
	#     _apply_movement(input_sync.movement_input, delta)
