class_name LobbyComponent extends Component

signal lobby_created(id : int)
signal lobby_created_as_text(id : String)

var lobby_id : int = 0
var peer : SteamMultiplayerPeer
@export var player_scene: PackedScene
var is_host : bool = false
var is_joining : bool = false

var player_objects : Dictionary[int, Node] = {}

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func invite_tester(invite_lobby_id : int):
	for friend_index in range(Steam.getFriendCount(Steam.FriendFlags.FRIEND_FLAG_ALL)):
		var friend_id = Steam.getFriendByIndex(friend_index, Steam.FriendFlags.FRIEND_FLAG_ALL)
		if Steam.getFriendPersonaName(friend_id) == "familiar_omen_testing":
			Steam.inviteUserToLobby(invite_lobby_id, friend_id)
			Steam.sendMessageToUser(friend_id, str(invite_lobby_id).to_utf8_buffer(), Steam.IDENTITY_TYPE_STEAMID, 0)
			print("Invited testing account")

func _ready() -> void:
	#print("Steam initialized: ", Steam.steamInit(480, true))
	print("Command line arguments: ", OS.get_cmdline_args())
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	
	var connect_lobby : bool = false
	
	for arg in OS.get_cmdline_args():
		if connect_lobby: join_lobby(arg.to_int())
		
		connect_lobby = arg == "+connect_lobby"

func host_lobby():
	if lobby_id: return
	is_host = true
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 3)

func join_lobby(new_lobby_id : int):
	if lobby_id: return
	is_joining = true
	Steam.joinLobby(new_lobby_id)

func _on_lobby_joined(new_lobby_id : int, _permissions : int, _locked : bool, _response : int):
	if not is_joining: return
	
	is_joining = false
	lobby_id = new_lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer

func _on_lobby_created(result : int, new_lobby_id : int):
	if result == Steam.Result.RESULT_OK:
		lobby_id = new_lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player()
		
		lobby_created.emit(lobby_id)
		lobby_created_as_text.emit(str(lobby_id))
		print("Lobby ID: ", lobby_id)
		#invite_tester(new_lobby_id)

func _add_player(id : int = 1):
	print("Player joined: ", id)
	var player = player_scene.instantiate()
	Components.get_first(InputComponent).on(player).set_multiplayer_authority(id)
	#player.set_multiplayer_authority(id)
	player.name = "Player_" + str(id)
	player_objects.set(id, player)
	entity.add_child.call_deferred(player)

func _remove_player(id : int):
	print("Player left: ", id)
	var player = player_objects.get(id)
	
	if player:
		player.queue_free()
		player_objects.erase(id)
