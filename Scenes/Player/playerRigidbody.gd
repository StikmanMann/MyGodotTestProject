class_name PlayerRB
extends RigidBody3D

@onready var camera = $BoundingBox/RotationHelper/Camera3D
@onready var rotation_helper = $BoundingBox/RotationHelper
@onready var bounding_box = $BoundingBox

var max_speed = 10
var acceleration = max_speed * 10
var max_air_speed = 1
var air_acceleration = max_speed * 20

var friction = 16

var jump_velocity = 5


var currentSpeed = 0
var vel : Vector3
#var friction : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var MOUSE_SENSITIVITY = 0.001

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE && event.is_pressed():
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	if event is InputEventMouseMotion:
		
		rotation_helper.rotate_x(-deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * 50))
		#print(event.relative.x * MOUSE_SENSITIVITY * -1)
		bounding_box.rotate_y(event.relative.x * MOUSE_SENSITIVITY * -1)
		#rotation_helper.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		#var camera_rot = rotation_helper.rotation_degrees
		#camera_rot.x = clamp(camera_rot.x, -70, 70)
		#rotation_helper.rotation_degrees = camera_rot
	
	if event is InputEventKey:
		#print(event.as_text_keycode())
		if event.as_text_keycode() == "T":
			camera.transform = $BoundingBox/ThirdPerson.transform
		elif event.as_text_keycode() == "F":
			camera.transform = $BoundingBox/FirstPerson.transform



func _physics_process(delta):
	# Add the gravity.
	
	# Handle Jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		linear_velocity.y = jump_velocity
	
	var fB = 0 - Input.get_action_strength("forward") + Input.get_action_strength("backward", 1)
	var lR = 0 - Input.get_action_strength("left", 1) + Input.get_action_strength("right", 1)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector3 = Vector3(lR, 0, fB).rotated(Vector3.UP, bounding_box.rotation.y)
	
	var wishDir = input_dir.normalized()
	
	currentSpeed = linear_velocity.dot(wishDir)
	#print("Current speed: ", currentSpeed)
	#print(currentSpeed)
	
	if not is_on_floor() or Input.is_action_pressed("jump"):
		linear_velocity.y -= gravity * delta #speed in the air
		var addSpeed = clamp(max_air_speed - currentSpeed, 0, air_acceleration * delta)
		#print(addSpeed)
		linear_velocity += wishDir * addSpeed
	else:
		applyFriction(delta) #speed on floor
		var addSpeed = clamp(max_speed - currentSpeed, 0, acceleration * delta)
		linear_velocity += wishDir * addSpeed
	
	
		
	#print(Vector3(linear_velocity.x, 0, linear_velocity.z).length())
	

func applyFriction(delta):
	
	linear_velocity.x = lerp(linear_velocity.x, 0.0, delta * friction)
	linear_velocity.z = lerp(linear_velocity.z, 0.0, delta * friction)
	return vel

@onready var floor_checks = $BoundingBox/FloorChecks


var slope_limit_degrees = 45.0
var slope_limit_dot = cos(deg_to_rad(slope_limit_degrees))

func is_on_floor() -> bool:
	for directions in floor_checks.get_children():
		for floor_ray in directions.get_children():
			if floor_ray.is_colliding():
				var normal = floor_ray.get_collision_normal()
				#print(floor_ray.get_collider())
				if(normal.dot(Vector3.UP) >= slope_limit_dot):
					return true
			continue
	return false

const MAX_STANDABLE_ANGLE = deg_to_rad(45)
const GROUND_CHECK_DISTANCE = 0.1   

#func _check_on_ground() -> void:
	#var space_state = get_world_3d().direct_space_state
	#
	## Raycast straight down from the player
	#var from = global_transform.origin
	#var to = from - Vector3.UP * (GROUND_CHECK_DISTANCE + 2)#get_shape_radius())
	#
	#var result = space_state.intersect_ray(
		 #PhysicsRayQueryParameters3D(
			#
		#)
	#)
#
	#if result:
		#ground_normal = result.normal
		#
		## Check slope angle
		#var slope_angle = acos(clamp(ground_normal.dot(Vector3.UP), -1.0, 1.0))
		#var slope_ok = slope_angle <= MAX_STANDABLE_ANGLE
#
		## Check vertical velocity (like TF2: can't be going upward much)
		#var vertical_vel_ok = linear_velocity.y <= 0.1
#
		## Final check
		#is_on_ground = slope_ok and vertical_vel_ok
	#else:
		#is_on_ground = false
