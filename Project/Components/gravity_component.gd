class_name GravityComponent extends Component

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _velocity_component : Velocity3D

func _component_attached():
	_velocity_component = Components.get_or_add(Velocity3D).on(entity)

func _component_dettached():
	_velocity_component = null

func _physics_process(delta: float) -> void:
	_velocity_component.velocity = adjust_velocity(_velocity_component.velocity, delta)

func adjust_velocity(velocity : Vector3, delta : float):
	velocity.y -= gravity * delta
	return velocity
