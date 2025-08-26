extends Node3D


@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var interactable = $DoorHinge/Interactable
signal door_interact
func _ready():
	if animation_player:
		multiplayer.peer_connected.connect(_on_player_connected)
	interactable.player_interact.connect(open_door)

func _on_player_connected(id):
	if not multiplayer.is_server():
		animation_player.stop()
		animation_player.set_active(false)

var is_open = false
func open_door():
	door_interact.emit()
	if is_open:
		is_open = false
		animation_player.play("door_open")
	else:
		is_open = true
		animation_player.play_backwards("door_open")
	print("Opening")
