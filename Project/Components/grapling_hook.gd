class_name GrapplingGun extends State

@export
var force : float = 15
@export
var max_speed : float = 35
@export
var grabble_origin_offset : Vector3 = Vector3(0,1,0)

const RAY_LENGTH = 20

var _velocity_component : Velocity3D
var grabble_point : Vector3

func _component_attached():
	_velocity_component = Components.get_first(Velocity3D).on_ancestors_of(entity)
	var state_machine = Components.get_first(DispersedStateMachine).on_ancestors_of(entity) as DispersedStateMachine
	state_machine.register_state(self)

func valid():
	return Input.is_action_just_pressed("primary_click") and raycast()

func finished():
	return not Input.is_action_pressed("primary_click")

func interruptable():
	var position : Vector3 = _velocity_component.entity.global_position
	var from_to = (grabble_point - position - grabble_origin_offset)
	var length = from_to.length()
	
	return length < 1.1

func enter():
	grabble_point = raycast()

func exit():
	grabble_point = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var position : Vector3 = _velocity_component.entity.global_position
	var from_to = (grabble_point - position - grabble_origin_offset)
	var direction = from_to.normalized()
	var length = from_to.length()
	
	#_velocity_component.velocity = lerp(_velocity_component.velocity, direction * max_speed, delta * force * sqrt(length))
	# the above is technically unsafe...
	_velocity_component.velocity = move_towards(_velocity_component.velocity, direction * max_speed, delta * force * 30 * sqrt(length))

func move_towards(from : Vector3, to : Vector3, amount : float):
	var direction = (to - from).normalized()
	var difference = (to - from).length()
	
	return from + (direction * amount).limit_length(difference)

func raycast():
	var space_state : PhysicsDirectSpaceState3D = entity.get_world_3d().direct_space_state
	
	var origin = entity.global_position
	var end = origin - entity.global_transform.basis.z * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	return space_state.intersect_ray(query).get("position", Vector3.ZERO)
