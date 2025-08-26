extends Control

@onready var host_game = $Panel/VBoxContainer/HostGame
@onready var join_as_player_2 = $Panel/VBoxContainer/JoinAsPlayer2
@onready var text_edit = $Panel/VBoxContainer/TextEdit
@onready var deine_ip = $Panel/VBoxContainer/DeineIP

func _ready():
	host_game.pressed.connect(become_host)
	join_as_player_2.pressed.connect(join)
	#var _local_ips = IP.resolve_hostname_addresses()
	#for ip in local_ips:
	#	deine_ip.text += "\n" + ip # Converts the array into a comma-separated string


func become_host():
	print("become host")
	self.hide()
	MultiplayerManager.become_host()

func join():
	print("Join as palyer 2")
	self.hide()
	MultiplayerManager.join_host(text_edit.text)
