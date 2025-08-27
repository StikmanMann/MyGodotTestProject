class_name Interactable
extends Area3D

signal player_interact

func _ready():
	player_interact.connect(_debug)
	

func _debug():
	print("ICH WURDE ITNERGAIRERT!")
