extends Node

enum errors{
	NO_OBJECTS_IN_GROUP
}

var land_nav : Navigation2D
var water_nav : Navigation2D

func get_random_object_in_group(group : String):
	var group_objects = get_tree().get_nodes_in_group(group)
	if group_objects.empty():
		return errors.NO_OBJECTS_IN_GROUP
	return group_objects[randi() % group_objects.size()]

func is_on_land(point : Vector2):
	return land_nav.get_closest_point(point).distance_squared_to(point) < 1

func is_in_water(point : Vector2):
	return water_nav.get_closest_point(point).distance_squared_to(point) < 1


