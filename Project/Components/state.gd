@abstract
class_name State extends Component

func enter():
	pass

func exit():
	pass

func valid():
	return false

func finished():
	return true

func interruptable():
	return true
