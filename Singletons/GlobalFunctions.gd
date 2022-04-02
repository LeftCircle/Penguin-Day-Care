extends Node

enum errors{
	NO_OBJECTS_IN_GROUP
}

func get_random_object_in_group(group : String):
	var group_objects = get_tree().get_nodes_in_group(group)
	if group_objects.empty():
		return errors.NO_OBJECTS_IN_GROUP
	return group_objects[randi() % group_objects.size()]
