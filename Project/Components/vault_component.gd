class_name VaultComponent extends State

var vault_range := 1.0
var vault_height := 1.0
var vault_clearance := 2.0

var is_grounded : bool
var _velocity_component : Velocity3D
var input : InputComponent

var vaulting_to : Vector3

func _component_attached():
	var _is_grounded_component : IsGroundedComponent = Components.get_first(IsGroundedComponent).on_ancestors_of(entity)
	var state_machine = Components.get_first(DispersedStateMachine).on_ancestors_of(entity) as DispersedStateMachine
	input = Components.get_first(InputComponent).on_ancestors_of(entity)
	state_machine.register_state(self)
	_velocity_component = Components.get_first(Velocity3D).on_ancestors_of(entity)
	await detached
	_is_grounded_component = null
	_velocity_component = null

func valid():
	if input.vault:
		var target_ledge = raycast_look_at()
		var target_point = raycast_target()
		
		return target_ledge and target_point and not is_grounded
	return false

func interruptable():
	return false

func finished():
	return not input.vault or (_velocity_component.entity.global_position.y > vaulting_to.y)

func enter():
	vaulting_to = raycast_target() + Vector3.UP * 0.2

func exit():
	_velocity_component.velocity.y = lerp(_velocity_component.velocity.y, 0.0, 1.0)

func _physics_process(delta: float) -> void:
	var position : Vector3 = _velocity_component.entity.global_position
	var from_to = (vaulting_to - position)
	var direction = from_to.normalized()
	
	_velocity_component.velocity = lerp(_velocity_component.velocity, direction + Vector3.UP * 3, delta * 50)

func raycast_look_at():
	return raycast(entity.global_position, -entity.global_transform.basis.z, vault_range)

func raycast_up():
	return raycast(entity.global_position, Vector3.UP, vault_height + vault_clearance)

func raycast_target():
	return raycast(raycast_look_at() - entity.global_transform.basis.z / 2 + Vector3.UP * vault_height, Vector3.DOWN, vault_height)

func raycast(from, dir, distance):
	var space_state : PhysicsDirectSpaceState3D = entity.get_world_3d().direct_space_state
	
	var origin = from
	var end = origin + dir * distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	return space_state.intersect_ray(query).get("position", Vector3.ZERO)
