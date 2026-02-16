class_name IsGroundedComponent extends Component

var is_grounded:
	set(v): pass
	get: return entity.get_indexed(_external_property).call()
	
var _external_property : NodePath

func _component_attached():
	if entity is CharacterBody3D:
		_external_property = ^":is_on_floor"
	elif entity is CharacterBody2D:
		_external_property = ^":is_on_floor"
	else:
		push_warning("Unsupported node type: ", entity.get_class())
