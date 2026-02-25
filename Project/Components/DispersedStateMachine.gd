class_name DispersedStateMachine extends Component

var states : Array[State] = []
var current_state : State

func _init() -> void:
	process_physics_priority = -10
	
	child_entered_tree.connect(redirect_component_attachment)

func redirect_component_attachment(child):
	if child is State:
		child._detach_component()
		child._attach_component(entity)
		register_state(child)

func register_state(state : State):
	state.process_mode = Node.PROCESS_MODE_DISABLED
	states.append(state)

func deregister_state(state : State):
	states.erase(state)
	state.process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(_delta: float) -> void:
	if current_state:
		if current_state.finished():
			exit_state()
		elif current_state.interruptable():
			enter_first_valid_state()
	
	if not current_state:
		enter_first_valid_state()

func enter_first_valid_state():
	for state in states:
		if state.valid() and not state == current_state:
			enter_state(state)
			break

func enter_state(state : State):
	exit_state()
	state.enter()
	state.process_mode = Node.PROCESS_MODE_INHERIT
	current_state = state

func exit_state():
	if current_state:
		current_state.process_mode = Node.PROCESS_MODE_DISABLED
		current_state.exit()
		current_state = null
