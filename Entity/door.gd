extends Node3D


@onready var animation_player = $AnimationPlayer
@onready var interactable = $DoorHinge/Interactable
signal door_interact
func _ready():
	
	interactable.player_interact.connect(open_door)



var is_open = false
func open_door():
	door_interact.emit()
	if is_open:
		animation_player.play_backwards("door_open")
		is_open = false
	else:
		animation_player.play("door_open")
		is_open = true
