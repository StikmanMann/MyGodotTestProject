class_name SecurityMainMonitorSetup
extends Node3D
@onready var sub_viewport = $SubViewport
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var camera_3d : Camera3D = $SubViewport/Camera3D

func _ready():
	_update_monitor_children()


func _update_monitor_children():
	for child in get_children():
		if child is Monitor:
			var monitor: Monitor = child
			monitor.monitor_clicked.connect(_set_main_monitor)
			


func _set_main_monitor(clicked_monitor: Monitor):
	var security_camera: Camera3D = clicked_monitor.security_camera._get_camera()
	print("Setting camera transform!")
	camera_3d.transform = security_camera.transform
	# or better: just set monitor.texture = security_camera.sub_viewport.get_texture()
