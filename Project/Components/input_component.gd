class_name InputComponent extends Component

signal rotated(x, y)

const networked_properties := ["movement", "jump", "sprint", "vault", "grapple", "grap", "rotation_x", "rotation_y"]

@export var camera : Camera3D
@export var audio : AudioListener3D
@export var Sensitivity = 0.003

var movement : Vector2
var jump : bool
var sprint : bool
var vault : bool
var grapple : bool
var grap : bool

var rotation_x : float
var rotation_y : float

var is_enabled : bool:
	get: return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and is_multiplayer_authority()

func _init() -> void:
	process_physics_priority = 100

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not is_enabled: return
	
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.x * Sensitivity
		rotation_y -= event.relative.y * Sensitivity
		rotated.emit(rotation_x, rotation_y)
	elif event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta: float) -> void:
	if is_enabled:
		gather_input()
	elif Input.is_action_just_pressed("primary_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func gather_input():
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
	rotated.emit(rotation_x, rotation_y)

@rpc("call_local")
func set_auth(player_id : int):
	set_multiplayer_authority(player_id)
	if is_multiplayer_authority():
		camera.make_current()
		audio.make_current()
