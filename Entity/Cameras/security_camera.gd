class_name SecurityCamera
extends Node3D

@export var cam: Camera3D = null
@onready var sub_viewport: Viewport = $SubViewport
@onready var monitor: Sprite3D = $Monitor  # Or Sprite3D, MeshInstance3D, etc.

func _ready():
	if cam is Camera3D:
		_set_camera(cam)
		
	else:
		print("No camera!")
	

	

func _set_camera(camera: Camera3D):
	var camera_clone = camera.duplicate()
	
	sub_viewport.add_child(camera_clone)
	
	# Display the viewport texture on the monitor
	monitor.texture = sub_viewport.get_texture()

func _get_camera() -> Camera3D:
	return sub_viewport.get_camera_3d()
