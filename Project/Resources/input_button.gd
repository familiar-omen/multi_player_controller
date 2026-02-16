class_name InputButton extends Resource

@export var action_name : StringName

var is_just_pressed : bool:
	get: return Input.is_action_just_pressed(action_name)
var is_pressed : bool:
	get: return Input.is_action_pressed(action_name)
var is_just_released : bool:
	get: return Input.is_action_just_released(action_name)
