class_name InputComponent extends Component

var movement : Vector2

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		movement = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

@rpc("call_local")
func set_auth(player_id : int):
	set_multiplayer_authority(player_id)
