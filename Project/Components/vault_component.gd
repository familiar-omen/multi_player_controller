class_name VaultComponent extends State

@export var vault_range := 1.0
@export var vault_height := 1.0

@export_group("Nodes", "c_")
@export var c_grounded : IsGroundedComponent
@export var c_velocity : Velocity3D
@export var c_input : InputComponent
@export var c_shapecast : RayCast3D

var vaulting_to : Vector3

func _ready() -> void:
	c_shapecast.add_exception(entity)

func valid():
	if c_input.vault:
		var target_point = raycast_target()
		
		return target_point and not c_grounded.is_grounded and (target_point.y > c_velocity.entity.global_position.y)
	return false

func interruptable():
	return false

func finished():
	return not c_input.vault or (c_velocity.entity.global_position.y > vaulting_to.y)

func enter():
	vaulting_to = raycast_target() + Vector3.UP * 0.2

func exit():
	c_velocity.velocity.y = 0.0

func _physics_process(delta: float) -> void:
	var position : Vector3 = c_velocity.entity.global_position
	var from_to = (vaulting_to - position)
	var direction = from_to.normalized()
	
	c_velocity.velocity = lerp(c_velocity.velocity, direction + Vector3.UP * 3, delta * 50)

func raycast_target():
	if c_shapecast.is_colliding():
		return raycast(c_shapecast.get_collision_point() - c_shapecast.get_collision_normal() / 2 + Vector3.UP * vault_height, Vector3.DOWN, vault_height)
	else:
		return false

func raycast(from, dir, distance):
	var space_state : PhysicsDirectSpaceState3D = entity.get_world_3d().direct_space_state
	
	var origin = from
	var end = origin + dir * distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	return space_state.intersect_ray(query).get("position", Vector3.ZERO)
