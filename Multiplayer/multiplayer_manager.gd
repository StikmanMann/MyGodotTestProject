extends Node

const SERVER_PORT = 25565
const SERVER_IP = "127.0.0.1"

var multiplayer_scene = preload("res://Multiplayer/Player/PlayerRigidbodyMP.tscn")

var _players_spawn_node

func _ready():
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--host":
			become_host()

func become_host():
	print("JA")
	
	_players_spawn_node = get_tree().current_scene.get_node("Players")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(add_player_to_game)
	multiplayer.peer_disconnected.connect(del_player)
	
	remove_single_player()
	
	add_player_to_game(1)

func join_host(ip):
	print("NO")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(ip, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	remove_single_player()
	
	

func add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)

func del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	

func remove_single_player():
	print("removing player")
	var player_to_remove = get_tree().current_scene.get_node("PlayerRigidbody")
	player_to_remove.queue_free()
