class_name Monitor
extends Node3D

signal monitor_clicked(monitor: Monitor)

@export var cam_fps := 5
@export var camera: Camera3D = null
@export var render_area: Area3D = null

@onready var interactable: Interactable = $Interactable
@onready var security_camera: SecurityCamera = $SecurityCamera

func _ready():
	security_camera._set_fps(cam_fps)
	security_camera._set_camera(camera)
	interactable.player_interact.connect(_monitor_clicked)
	if render_area is Area3D:
		render_area.monitoring = true
		render_area.body_entered.connect(_show_camera)
		render_area.body_exited.connect(_hide_camera)
	else:
		print("No render area3d found! Unoptimised bs")

func _monitor_clicked():
	monitor_clicked.emit(self)
	

func _hide_camera(body: Node):
	if body is PlayerRBMP:
		var player: PlayerRBMP = body
		if multiplayer.get_unique_id() == player.player_id:
			print("Hiding camera!")
			self.visible = false


func _show_camera(body: Node):
	if body is PlayerRBMP:
		var player: PlayerRBMP = body
		if multiplayer.get_unique_id() == player.player_id:
			self.visible = true
			print("Showing camera!")
			

func _set_fps(fps: int):
	security_camera._set_fps(cam_fps)
