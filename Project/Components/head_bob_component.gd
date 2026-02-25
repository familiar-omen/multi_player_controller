class_name HeadBobComponent extends Component

signal foot_step

@export var frequency = 2.0
@export var amplitude = 0.08

@export_group("Nodes", "c_")
@export var c_velocity : Velocity3D
@export var c_grounded : IsGroundedComponent
@export var c_head : Node3D
@export var c_audoplayer : AudioStreamPlayer3D

var velocity : Vector3:
	set = set_velocity
var scaled_time : float
var side : int = 1

func set_velocity(value):
	velocity = value

func _enter_tree() -> void:
	c_velocity.velocity_changed.connect(set_velocity)
	process_physics_priority = c_velocity.process_physics_priority + 1
	
	foot_step.connect(func():
		c_audoplayer.pitch_scale = randfn(0.6, 0.1)
		c_audoplayer.volume_db = randfn(-3, 0.1)
		
		c_audoplayer.pitch_scale += c_velocity.velocity.length() * 0.1
		c_audoplayer.volume_db += c_velocity.velocity.length() * 0.2
		
		c_audoplayer.play(0)
		await get_tree().create_timer(0.3).timeout
		c_audoplayer.stop()
	)

func _physics_process(delta: float) -> void:
	if not c_grounded.is_grounded: return
	
	scaled_time += delta * Vector2(velocity.x, velocity.z).length()
	
	var pos = Vector3.ZERO
	pos.y = sin(scaled_time * frequency) * amplitude
	pos.x = cos(scaled_time * frequency / 2) * amplitude
	
	var cur_side = sign(cos(scaled_time * frequency / 2))
	
	if side != cur_side:
		foot_step.emit()
		side = cur_side
	
	c_head.transform.origin = pos
