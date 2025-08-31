class_name PickupMP 
extends Node3D




@export var max_heaviness: float = 30.0      # max object mass allowed
@export var hold_distance: float = 3.0       # how far in front of player to hold
@export var hold_strength: float = 8.0       # how strongly we pull the object toward target
@export var damping: float = 20.0            # smoothness of movement

@onready var pickup_ray = %PickupRay

var held_object: RigidBody3D = null


func _physics_process(delta: float) -> void:
	# --- Pickup / Drop toggle ---
	if multiplayer.is_server():
		# --- If holding an object, move it toward the target point ---
		if held_object:
			_move_held_object(delta)

func pickup() -> void:
	if held_object:
		_drop_object()
	else:
		_try_pickup()

func _try_pickup() -> void:
	if pickup_ray.is_colliding():
		var obj = pickup_ray.get_collider()
		if obj is RigidBody3D and obj.mass <= max_heaviness:
			held_object = obj
			# disable gravity while held (optional)
			held_object.gravity_scale = 0


func _drop_object() -> void:
	if held_object:
		held_object.gravity_scale = 1
		held_object = null


func _move_held_object(delta: float) -> void:
	if not held_object: return

	var target_pos = pickup_ray.global_transform.origin + pickup_ray.global_transform.basis.z * -hold_distance
	var to_target = target_pos - held_object.global_transform.origin

	# Smooth velocity-based pulling
	held_object.linear_velocity = held_object.linear_velocity.lerp(to_target * hold_strength, damping * delta)

	# Optional: dampen angular spin so object is stable
	held_object.angular_velocity = held_object.angular_velocity.lerp(Vector3.ZERO, damping * delta)
