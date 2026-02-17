class_name InputComponent extends Component

@export var camera : Camera3D
@export var audio : AudioListener3D
var movement : Vector2
var jump : bool
var sprint : bool
var vault : bool
var grapple : bool
var grap : bool

func _init() -> void:
	# Process before state_machines
	process_physics_priority = -11

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		movement = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		jump = Input.is_action_just_pressed("jump")
		sprint = Input.is_action_pressed("sprint")
		grapple = Input.is_action_pressed("secondary_click")
		grap = Input.is_action_pressed("primary_click")
		vault = Input.is_action_pressed("jump")

@rpc("call_local")
func set_auth(player_id : int):
	set_multiplayer_authority(player_id)
	entity.set_multiplayer_authority(player_id)
	if is_multiplayer_authority():
		camera.make_current()
		audio.make_current()
