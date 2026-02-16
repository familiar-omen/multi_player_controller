class_name HeadBobComponent extends Component

signal foot_step

@export var frequency = 2.0
@export var amplitude = 0.08

var _velocity_component : Velocity3D
var _is_grounded_component : IsGroundedComponent

var velocity : Vector3:
	set = set_velocity
var scaled_time : float
var side : int = 1

func set_velocity(value):
	velocity = value

func _enter_tree() -> void:
	foot_step.connect(func():
		$"../../../AudioStreamPlayer3D".pitch_scale = randfn(1, 0.1)
		$"../../../AudioStreamPlayer3D".volume_db = randfn(0, 0.1)
		if not Input.is_action_pressed("sprint"):
			$"../../../AudioStreamPlayer3D".volume_db = -2
			$"../../../AudioStreamPlayer3D".pitch_scale -= 0.2
		$"../../../AudioStreamPlayer3D".play(0)
		await get_tree().create_timer(0.3).timeout
		$"../../../AudioStreamPlayer3D".stop()
	)

func _component_attached():
	_is_grounded_component = Components.get_first(IsGroundedComponent).on_ancestors_of(entity)
	_velocity_component = Components.get_first(Velocity3D).on_ancestors_of(entity)
	_velocity_component.velocity_changed.connect(set_velocity)
	process_physics_priority = _velocity_component.process_physics_priority + 1

func _component_dettached():
	_velocity_component = null
	_is_grounded_component = null

func _physics_process(delta: float) -> void:
	if not _is_grounded_component.is_grounded: return
	
	scaled_time += delta * Vector2(velocity.x, velocity.z).length()
	
	var pos = Vector3.ZERO
	pos.y = sin(scaled_time * frequency) * amplitude
	pos.x = cos(scaled_time * frequency / 2) * amplitude
	
	var cur_side = sign(cos(scaled_time * frequency / 2))
	
	if side != cur_side:
		foot_step.emit()
		side = cur_side
	
	entity.transform.origin = pos
