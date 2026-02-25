class_name IsGroundedComponent extends Component

@export var friction : float = 0.0
@export var c_velocity : Velocity3D

var is_grounded:
	set(v): pass
	get: return entity.get_indexed(_external_property).call()
	
var _external_property : NodePath

func _component_attached():
	if entity is CharacterBody3D:
		_external_property = ^":is_on_floor"
	elif entity is CharacterBody2D:
		_external_property = ^":is_on_floor"
	else:
		push_warning("Unsupported node type: ", entity.get_class())

func _physics_process(delta: float) -> void:
	if c_velocity and is_grounded:
		c_velocity.velocity = move_towards(c_velocity.velocity, Vector3.ZERO, delta * friction)

func move_towards(from : Vector3, to : Vector3, amount : float):
	var direction = (to - from).normalized()
	var difference = (to - from).length()
	
	return from + (direction * amount).limit_length(difference)
