class_name Monitor
extends Node3D

signal monitor_clicked(monitor: Monitor)

@export var camera: Camera3D = null

@onready var interactable: Interactable = $Interactable
@onready var security_camera = $SecurityCamera

func _ready():
	security_camera._set_camera(camera)
	interactable.player_interact.connect(_monitor_clicked)

func _monitor_clicked():
	monitor_clicked.emit(self)
