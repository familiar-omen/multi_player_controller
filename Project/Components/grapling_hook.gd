class_name GrapplingGun extends State

@export var force : float = 15
@export var max_speed : float = 35
@export var grabble_origin_offset : Vector3 = Vector3(0,1,0)

@export_group("Nodes", "c_")
@export var c_shapecast : ShapeCast3D
@export var c_velocity : Velocity3D
@export var c_input : InputComponent

var grabble_point : Vector3

func _ready() -> void:
	c_shapecast.add_exception(entity)

func valid():
	return c_input.grapple and c_shapecast.is_colliding()

func finished():
	return not c_input.grapple

func interruptable():
	var position : Vector3 = c_velocity.entity.global_position
	var from_to = (grabble_point - position - grabble_origin_offset)
	var length = from_to.length()
	
	return length < 1.1

func enter():
	grabble_point = c_shapecast.get_collision_point(0)

func exit():
	grabble_point = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var position : Vector3 = c_velocity.entity.global_position
	var from_to = (grabble_point - position - grabble_origin_offset)
	var direction = from_to.normalized()
	var length = from_to.length()
	
	c_velocity.velocity = move_towards(c_velocity.velocity, direction * max_speed, delta * force * 30 * sqrt(length))

func move_towards(from : Vector3, to : Vector3, amount : float):
	var direction = (to - from).normalized()
	var difference = (to - from).length()
	
	return from + (direction * amount).limit_length(difference)
