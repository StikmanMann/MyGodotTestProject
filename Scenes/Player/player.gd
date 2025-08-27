class_name Player
extends CharacterBody3D

@onready var camera = $BoundingBox/RotationHelper/Camera3D
@onready var rotation_helper = $BoundingBox/RotationHelper
@onready var textHud = $Control/RichTextLabel

var max_speed = 10
var acceleration = max_speed * 10
var max_air_speed = 1
var air_acceleration = max_air_speed * 10

var friction = 16

var jump_velocity = 5

var currentSpeed = 0
var vel : Vector3
#var friction : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var MOUSE_SENSITIVITY = 0.05

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(-deg_to_rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		#rotation_helper.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	
	if event is InputEventKey:
		#print(event.as_text_keycode())
		if event.as_text_keycode() == "B":
			pass


func _physics_process(delta):
	# Add the gravity.
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	var fB = 0 - Input.get_action_strength("forward") + Input.get_action_strength("backward", 1)
	var lR = 0 - Input.get_action_strength("left", 1) + Input.get_action_strength("right", 1)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector3 = Vector3(lR, 0, fB).rotated(Vector3.UP, self.rotation.y)
	
	var wishDir = input_dir.normalized()
	
	var currentSpeed = velocity.dot(wishDir)
	print("Current speed: ", currentSpeed)
	#print(currentSpeed)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		var addSpeed = clamp(max_air_speed - currentSpeed, 0, air_acceleration * delta)
		#print(addSpeed)
		velocity += wishDir * addSpeed
	else:
		applyFriction(delta)
		var addSpeed = clamp(max_speed - currentSpeed, 0, acceleration * delta)
		velocity += wishDir * addSpeed
	
	
		
	print(velocity)
	move_and_slide()
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 0.3)
			col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())

func applyFriction(delta):
	
	velocity.x = lerp(velocity.x, 0.0, delta * friction)
	velocity.z = lerp(velocity.z, 0.0, delta * friction)
	return vel
