class_name LookComponent extends Component

@export var vertical_look : Node3D
@export var input : InputComponent

func _ready() -> void:
	input.rotated.connect(rotate)

func rotate(x, y):
	entity.rotation.y = x
	vertical_look.rotation.x = y
	vertical_look.rotation.x = clamp(vertical_look.rotation.x, deg_to_rad(-85), deg_to_rad(89))
