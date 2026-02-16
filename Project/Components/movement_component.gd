class_name MovementComponent extends State

@export var SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5

var _velocity_component : Velocity3D
var _is_grounded_compnent : IsGroundedComponent

@export var move_input : InputVector
@export var sprint_button : InputButton
@export var jump_button : InputButton

func _component_attached():
	var state_machine = Components.get_or_add(DispersedStateMachine).on(entity) as DispersedStateMachine
	_velocity_component = Components.get_or_add(Velocity3D).on(entity)
	_is_grounded_compnent = Components.get_or_add(IsGroundedComponent).on(entity)
	state_machine.register_state(self)
	await detached
	if state_machine:
		state_machine.deregister_state(self)
	state_machine = null
	_velocity_component = null
	_is_grounded_compnent = null

func valid():
	return move_input.vector or jump_button.is_just_pressed

func interruptable():
	return true

func finished():
	return _velocity_component.velocity == Vector3.ZERO

func _physics_process(delta: float) -> void:
	_velocity_component.velocity = adjust_velocity(_velocity_component.velocity, delta)

func adjust_velocity(velocity : Vector3, delta : float):
	var grounded = _is_grounded_compnent.is_grounded
	
	if jump_button.is_just_pressed and grounded:
		velocity.y = JUMP_VELOCITY
	
	var speed = SPRINT_SPEED if sprint_button.is_pressed else SPEED
	
	var input_dir = move_input.vector
	var direction = (entity.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction or grounded:
		velocity.x = lerpf(velocity.x, direction.x * speed, delta * speed)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta * speed)
	
	return velocity
