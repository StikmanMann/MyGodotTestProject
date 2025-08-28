class_name SecurityCamera
extends Node3D

@export var cam: Camera3D = null
@onready var sub_viewport: Viewport = $SubViewport
@onready var monitor: Sprite3D = $Monitor  # Or Sprite3D, MeshInstance3D, etc.
@onready var camera_3d = $SubViewport/Camera3D

func _ready():
	if cam is Camera3D :
		_set_camera(cam)
	elif get_parent() is not Monitor:
		print("No camera!")

@export var cam_fps := 5

var _accum_time := 0.0

func _process(delta: float) -> void:
	_accum_time += delta
	if _accum_time >= 1.0 / cam_fps:
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		_accum_time = 0.0

func _set_camera(camera: Camera3D):
	camera_3d.transform = camera.global_transform
	camera.queue_free()
	# Display the viewport texture on the monitor
	monitor.texture = sub_viewport.get_texture()

func _get_camera() -> Camera3D:
	return sub_viewport.get_camera_3d()

func _set_fps(fps: int):
	cam_fps = fps
