class_name InteractorMP
extends Node3D


@onready var interact_ray = $InteractRay

func _interact() -> void:
	if interact_ray.is_colliding():
		var obj = interact_ray.get_collider()
		print(obj)
		if obj is Interactable:
			print("Jetzt ist es ezit")
			obj.interact.emit()
