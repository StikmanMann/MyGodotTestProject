class_name interactor
extends Node3D


@onready var interact_ray = $InteractRay

func _input(event):
	if event.is_action_pressed("interact"):
		_interact()

func _interact() -> void:
	if interact_ray.is_colliding():
		var obj = interact_ray.get_collider()
		print(obj)
		if obj is Interactable:
			#print("Jetzt  ist es ezit")
			obj.player_interact.emit()
