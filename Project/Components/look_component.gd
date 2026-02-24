class_name LookComponent extends Component

@export var vertical_look : Node3D
@export var Sensitivity = 0.003

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_multiplayer_authority():
			rotate.rpc(-event.relative.x * Sensitivity, -event.relative.y * Sensitivity)
	elif event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

@rpc("call_local")
func rotate(x, y):
	entity.rotate_y(x)
	vertical_look.rotate_x(y)
	vertical_look.rotation.x = clamp(vertical_look.rotation.x, deg_to_rad(-85), deg_to_rad(89))
