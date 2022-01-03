extends Node2D

# The URL we will connect to
export var websocket_url = "ws://127.0.0.1:8090/ws/room/test39/"

# Our WebSocketClient instance
var _client = WebSocketClient.new()
var _client2 = WebSocketClient.new()
func _ready():
	print("Start")
	print(_client)
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	var headers = ["Authorization: JWT eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjQxMjkxOTE3LCJpYXQiOjE2NDEyMDU1MTcsImp0aSI6IjIwN2IyNDY1MGVhZjRhNjlhNzk1ODJhZDA3YWE4MTVlIiwidXNlcl9pZCI6ImJkMTYwNTA4LTAwYjYtNDBmMS1iNGJjLTY5M2FkNDc4Y2ExNSIsImlkIjoiYmQxNjA1MDgtMDBiNi00MGYxLWI0YmMtNjkzYWQ0NzhjYTE1In0.i8m-RzR2cUns8mcNw9wND1YSDBdH_CFl26oXcxNtEwA"]
	# Initiate connection to the given URL.
	var err2 = _client2.connect_to_url(websocket_url, PoolStringArray(), false ,headers )
	var err = _client.connect_to_url(websocket_url, PoolStringArray(), false ,headers )
	print(err)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	var msg = "{\"type\":\"move\" , \"take\" : 5}"
	print(msg.to_utf8())
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_client.get_peer(1).put_packet(msg.to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()
