class_name InputVector extends Resource

@export var up : StringName
@export var down : StringName
@export var left : StringName
@export var right : StringName

var vector: Vector2:
	get: return Input.get_vector(left, right, up, down)
