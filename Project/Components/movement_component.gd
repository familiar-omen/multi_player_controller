class_name MovementComponent extends State

@export var SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5

var velocity : Velocity3D
var grounded : IsGroundedComponent
var input : InputComponent

#@export var move_input : InputVector
#@export var sprint_button : InputButton
#@export var jump_button : InputButton

func _component_attached():
	velocity = Components.get_or_add(Velocity3D).on(entity)
	grounded = Components.get_or_add(IsGroundedComponent).on(entity)
	input    = Components.get_or_add(InputComponent).on(entity)
	
	var state_machine = Components.get_or_add(DispersedStateMachine).on(entity) as DispersedStateMachine
	state_machine.register_state(self)

func valid():
	return input.movement
	 #or jump_button.is_just_pressed

func interruptable():
	return true

func finished():
	return velocity.velocity == Vector3.ZERO

func _physics_process(delta: float) -> void:
	velocity.velocity = adjust_velocity(velocity.velocity, delta)

func adjust_velocity(velocity : Vector3, delta : float):
	#var grounded = grounded.is_grounded
	
	#if jump_button.is_just_pressed and grounded:
		#velocity.y = JUMP_VELOCITY
	
	#var speed = SPRINT_SPEED if sprint_button.is_pressed else SPEED
	var speed = SPEED
	
	var input_dir = input.movement
	var direction = (entity.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction or grounded:
		velocity.x = lerpf(velocity.x, direction.x * speed, delta * speed)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta * speed)
	
	return velocity
