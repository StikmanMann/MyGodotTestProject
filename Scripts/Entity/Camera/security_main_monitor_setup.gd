class_name SecurityMainMonitorSetup
extends Node3D
@onready var sub_viewport = $SubViewport
@onready var camera_3d : Camera3D = $SubViewport/Camera3D
@export var cam_fps := 30
@export var monitors: Array[Monitor] = []

func _ready():
	_update_monitor_children()

var _accum_time := 0.0

func _process(delta: float) -> void:
	_accum_time += delta
	if _accum_time >= 1.0 / cam_fps:
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		_accum_time = 0.0

func _update_monitor_children():
	for monitor in monitors:
		await  monitor.ready
		monitor.monitor_clicked.connect(_set_main_monitor)
	_set_main_monitor(monitors[0])


func _set_main_monitor(clicked_monitor: Monitor):
	var security_camera: Camera3D = clicked_monitor.security_camera._get_camera()
	print("Setting camera transform!")
	camera_3d.transform = security_camera.transform
	# or better: just set monitor.texture = security_camera.sub_viewport.get_texture()
