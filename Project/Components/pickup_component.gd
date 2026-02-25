class_name PickupComponent extends State

@export var hold_point : Marker3D
@export var input : InputComponent
@export var connector : ComponentConnector

var held_object : Node3D

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if input.grap and not held_object:
		for connection in connector.connections.values():
			if IAmCollectible in connection:
				var interface = connection.get(IAmCollectible) as IAmCollectible
				
				grab.rpc(interface._attached_to.entity.get_path())
	
	if not input.grap and held_object:
		if held_object.get_parent() == hold_point:
			let_go.rpc()

@rpc("call_local")
func grab(node : NodePath):
	held_object = get_node(node)
	held_object.process_mode = Node.PROCESS_MODE_DISABLED
	held_object.global_position = hold_point.global_position
	held_object.reparent(hold_point)

@rpc("call_local")
func let_go():
	held_object.process_mode = Node.PROCESS_MODE_INHERIT
	held_object.reparent(get_tree().root.get_child(0))
	held_object = null
