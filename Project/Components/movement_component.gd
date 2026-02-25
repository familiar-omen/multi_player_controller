class_name MovementComponent extends State

@export var SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var acceleration = 8.0
@export var JUMP_VELOCITY = 4.5

@export_group("Nodes", "c_")
@export var c_velocity : Velocity3D
@export var c_grounded : IsGroundedComponent
@export var c_input : InputComponent

func valid():
	return c_input.movement or c_input.jump.pressed

func interruptable():
	return true

func finished():
	return c_velocity.velocity == Vector3.ZERO

func _physics_process(delta: float) -> void:
	c_velocity.velocity = adjust_velocity(c_velocity.velocity, delta)

func adjust_velocity(velocity : Vector3, delta : float):
	var grounded = c_grounded.is_grounded
	
	if c_input.jump.pressed and not c_input.jump.reacted and c_grounded.is_grounded:
		c_input.jump.reacted = true
		velocity.y = JUMP_VELOCITY
	
	var speed = SPRINT_SPEED if c_input.sprint else SPEED
	
	var input_dir = c_input.movement
	var direction = (entity.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction or grounded:
		velocity.x = move_toward(velocity.x, direction.x * speed, delta * speed * acceleration)
		velocity.z = move_toward(velocity.z, direction.z * speed, delta * speed * acceleration)
	
	return velocity
