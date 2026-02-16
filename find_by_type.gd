extends Node
const location := "typed_children"
const blank_dict := {}
const blank_array := []
static var class_dict := {}
static var dummies := {}

func _enter_tree() -> void:
	get_tree().node_added.connect(_register_node)
	get_tree().node_removed.connect(_deregister_node)
	for node in IterateChildren.new(get_tree().root.get_child(0)):
		_register_node(node)

static func _get_identifier(node : Node):
	var script = node.get_script()
	var cls = node.get_class()
	
	return script if script else cls

static func _get_type(type):
	if type is GDScript:
		return type
	elif class_dict.has(type):
		return class_dict.get(type)
	else:
		var instance : Node = type.new()
		var cls = instance.get_class()
		class_dict.set(type, cls)
		instance.free()
		return cls

static func _register_node(node : Node):
	var parent = node.get_parent()
	var identifier = _get_identifier(node)
	
	if not parent.has_meta(location):
		parent.set_meta(location, {})
	
	var dict = parent.get_meta(location)
	
	if not identifier in dict:
		dict.set(identifier, [])
	
	dict.get(identifier).append(node)

static func _deregister_node(node : Node):
	var identifier = _get_identifier(node)
	
	node.get_parent().get_meta(location, blank_dict).get(identifier, blank_array).erase(node)

## Return the first node matching the type in the seach area or null
func get_first(component_type) -> component_query:
	return component_query.new(component_type, _get_first)

## Return all nodes matching the type in the seach area
func get_all(component_type) -> component_query:
	return component_query.new(component_type, _get_all)

## Return the first node matching the type in the seach area or adds it to the search root
func get_or_add(component_type) -> component_query:
	return component_query.new(component_type, _get_or_add)

## Return the first node matching the type in the seach area or returns a dummy
## WARNING: Reading from the dummy will yield unpredictable values
func get_or_fake(component_type) -> component_query:
	return component_query.new(component_type, _get_or_add)

static func _get_first(_core : Node, type, iterator):
	var type_name = _get_type(type)
	for node in iterator:
		var value = node.get_meta(location, blank_dict).get(type_name, blank_array)
		if value: return value.front()
	return null

static func _get_all(_core : Node, type, iterator):
	var type_name = _get_type(type)
	var components = []
	for node in iterator:
		var value = node.get_meta(location, blank_dict).get(type_name, blank_array)
		if value: components.append_array(value)
	return components

static func _get_or_add(core : Node, type, iterator):
	var value = _get_first(core, type, iterator)
	
	if not value:
		value = type.new()
		core.add_child(value)
	
	return value
	
static func _get_or_fake(core : Node, type, iterator):
	var value = _get_first(core, type, iterator)
	
	if not value:
		if dummies.has(type):
			value = dummies.get(type)
		else:
			value = type.new()
			dummies.set(type, value)
	
	return value

class component_query:
	var _type
	var _function : Callable
	
	func _init(type, function):
		_type = type
		_function = function
	
	## Only seach the singular node for attached components
	func on(node : Node):
		return _function.call(node, _type, IterateSingle.new(node))
	
	## Search the node and all its owned children in tree order
	func owned_by(node : Node):
		return _function.call(node, _type, IterateOwned.new(node))
	
	## Search the node and all its children in tree order
	func on_children_of(node : Node):
		return _function.call(node, _type, IterateChildren.new(node))
	
	## Search the node and its ancestors in reverse tree order
	func on_ancestors_of(node : Node):
		return _function.call(node, _type, IterateAncestors.new(node))

class IterateSingle:
	var _search_root : Node

	func _init(search_root):
		_search_root = search_root

	func _iter_init(iter):
		iter[0] = _search_root
		return true

	func _iter_next(_iter):
		return false

	func _iter_get(iter):
		return iter

class IterateAncestors extends IterateSingle:
	func _iter_next(iter):
		iter[0] = iter[0].get_parent()
		
		return iter[0] != null

class IterateOwned extends IterateSingle:
	func _iter_next(iter):
		var index = -1
		var parent = iter[0]
		var searching = true
		var child : Node
		
		while searching:
			index += 1
			while index >= parent.get_child_count():
				index = parent.get_index() + 1
				parent = parent.get_parent()
				if not parent: return false
			
			child = parent.get_child(index)
			if not _search_root.is_ancestor_of(child): return false
			searching = child.owner != _search_root
		
		iter[0] = child
		
		return true

class IterateChildren extends IterateSingle:
	func _iter_next(iter):
		var index = 0
		var parent = iter[0]
		
		while index >= parent.get_child_count():
			index = parent.get_index() + 1
			parent = parent.get_parent()
			if not parent: return false
		
		var child = parent.get_child(index)
		if not _search_root.is_ancestor_of(child): return false
		iter[0] = child
		
		return true
