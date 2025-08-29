class_name Interactable
extends Area3D

signal interact


func _ready():
	interact.connect(_debug)
	

func _debug():
	print("ICH WURDE ITNERGAIRERT!")
