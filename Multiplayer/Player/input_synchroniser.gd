# InputSynchroniser.gd
extends MultiplayerSynchronizer
@onready var player_rigidbody_mp = $".."

# Replicated inputs (add these in the Synchronizer inspector "Properties" list)
var movement_input: Vector2 = Vector2.ZERO   # (x=strafe, y=forward)
var look_delta: Vector2 = Vector2.ZERO       # accumulated mouse delta since last physics tick
var jumping: bool = false


func _ready() -> void:
	# Only the local authority should read real inputs.
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_process_input(false)

func _process(_delta: float) -> void:
	# Local: poll WASD each frame
	movement_input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("backward") - Input.get_action_strength("forward")
	)
	
	look_delta = Vector2.ZERO
	jumping = Input.is_action_pressed("jump")
	if Input.is_action_just_pressed("interact"):
		_interact.rpc()

	

func _input(event: InputEvent) -> void:
	
		
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	# Local: accumulate raw mouse motion (compact, not whole events)
	if event is InputEventMouseMotion:
		look_delta = event.relative
		
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_pressed():
			player_rigidbody_mp.change_mouse_mode.emit()

@rpc("call_local")
func _interact():
	if multiplayer.is_server():
		player_rigidbody_mp.attempt_pickup = true
		player_rigidbody_mp.attempt_interact = true
