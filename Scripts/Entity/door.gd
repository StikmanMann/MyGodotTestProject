extends Node3D


@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var interactable = $DoorHinge/Interactable

@export var locked : bool = false


signal door_interact 
signal door_opened
signal door_closed
signal door_tried_open
 
@onready var door_hinge = $DoorHinge


func _ready():
	door_hinge.top_level = true #Damit das nicht so komisch warped idk wie ich sont fixe
	if animation_player:
		multiplayer.peer_connected.connect(_on_player_connected)
	interactable.interact.connect(try_open_door)

func _on_player_connected(_id):
	if not multiplayer.is_server():
		animation_player.stop()
		animation_player.set_active(false)

var is_open = false
func open_door():
	door_interact.emit()
	if is_open:
		door_opened.emit()
		is_open = false
		animation_player.play_backwards("door_open")
	else:
		door_closed.emit()
		is_open = true
		animation_player.play("door_open")
	print("Opening")

func try_open_door():
	door_tried_open.emit()
	if not locked:
		open_door()
	
