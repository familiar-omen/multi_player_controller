class_name InputComponent extends Component

const networked_properties := ["movement", "jump", "sprint", "vault", "grapple", "grap"]

@export var camera : Camera3D
@export var audio : AudioListener3D
var movement : Vector2
var jump : bool
var sprint : bool
var vault : bool
var grapple : bool
var grap : bool

func _init() -> void:
	process_physics_priority = 100

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		movement = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		jump = true if Input.is_action_just_pressed("jump") else jump
		sprint = Input.is_action_pressed("sprint")
		grapple = Input.is_action_pressed("secondary_click")
		grap = Input.is_action_pressed("primary_click")
		vault = Input.is_action_pressed("jump")
		
		var network_data : Dictionary[String, Variant] = {}
		
		move_networked_properties(self, network_data)
		
		share_network_data.rpc(network_data)

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		jump = false

func move_networked_properties(from, to):
	for property in networked_properties:
		to.set(property, from.get(property))

@rpc("unreliable")
func share_network_data(new_network_data : Dictionary):
	move_networked_properties(new_network_data, self)

@rpc("call_local")
func set_auth(player_id : int):
	set_multiplayer_authority(player_id)
	Components.get_first(LookComponent).on(entity).set_multiplayer_authority(player_id)
	#entity.set_multiplayer_authority(player_id)
	if is_multiplayer_authority():
		camera.make_current()
		audio.make_current()
