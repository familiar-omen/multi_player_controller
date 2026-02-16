class_name index_test extends Node

func _ready() -> void:
	FindByType.get_or_add(CharacterBody3D).on(self)
	FindByType.get_or_fake(CharacterBody3D).on(self)
	FindByType.get_first(CharacterBody3D).on(self)
	FindByType.get_all(CharacterBody3D).on(self)
	
	FindByType.get_first(CharacterBody3D).on(self)
	FindByType.get_first(CharacterBody3D).owned_by(self)
	FindByType.get_first(CharacterBody3D).on_children_of(self)
	FindByType.get_first(CharacterBody3D).on_ancestors_of(self)
	
	#print(type_string(typeof(CharacterBody3D)))
	
	#print(type_convert(CharacterBody3D, TYPE_STRING))
	
	
#var do = true

#func _process(_delta: float) -> void:
	#if do:
		#self.reparent(get_tree().root.get_child(0))
		#do = false
	#Components.get_or_fake(MovementComponent).on(node)
	#Components.add(ComponentConnector).on(node)
	#Components.remove(ComponentConnector).on(node)
	#Components.clear(ComponentConnector).on(node)
	
	#.on(node)
	#.owned_by(node)
	#.on_ancestor_of(node)
	
	#Components.require(MovementComponent).on_ancestor_of(node)
	#Components.require(MovementComponent).on_ancestor_of(node)
	
	#Component.require(Velocity3D).on(node)
