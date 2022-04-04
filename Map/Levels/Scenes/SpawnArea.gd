extends Area2D
class_name PenguinSpawner

export(PackedScene) var penguin_scene

onready var spawn_rect = $SpawnRect


func spawn_penguin(parent_node):
	var pos = get_random_spawn_position()
	var penguin = penguin_scene.instance()
	penguin.global_position = pos
	parent_node.add_child(penguin)


func get_random_spawn_position() -> Vector2:
	var x_range = spawn_rect.shape.extents.x
	var y_range = spawn_rect.shape.extents.y
	var rand_x = randi() % int(x_range)
	var rand_y = randi() % int(y_range)
	return global_position + Vector2(rand_x, rand_y)
