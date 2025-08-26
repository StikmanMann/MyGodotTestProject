class_name SecurityMainMonitorSetup
extends Node3D
@onready var sub_viewport = $SubViewport
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready():
	_update_monitor_children()

func _update_monitor_children():
	var children = self.get_children()
	for child in children:
		if child is Monitor:
			var monitor: Monitor = child
			monitor.monitor_clicked.connect(_set_main_monitor)
			print("Child added succesfully!")

func _set_main_monitor(clicked_monitor: Monitor):
	var security_camera: SecurityCamera = clicked_monitor.security_camera
	var camera = security_camera.sub_viewport.get_camera_3d()
	
	_remove_current_cam()
		#sub_viewport.get_child(0).queue_free()
	
	sub_viewport.add_child(clicked_monitor.camera.duplicate())
	
	#multiplayer_spawner.spawn(clicked_monitor.camera.duplicate())
	
	pass

func _remove_current_cam():
	var cam = sub_viewport.get_camera_3d()
	if cam != null:
		cam.queue_free()
