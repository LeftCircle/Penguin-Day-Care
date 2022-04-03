extends StaticBody2D
class_name BucketOfFish

export(PackedScene) var fish_scene
export(int, 0, 100) var fish_spawn_offset = 30
export(int, 0, 5) var max_fish_spawn = 3
const remove_after_x_steps = 60

# Only drop a fish if the penguin is not in this list
var collided_penguins = {}

onready var half_fish_spawn_offset = fish_spawn_offset / 2

func _ready():
	add_to_group("BucketOfFish")

func get_class():
	return "BucketOfFish"

func _physics_process(delta):
	_advance_collision_history()

func _advance_collision_history():
	for penguin in collided_penguins.keys():
		if collided_penguins[penguin] >= remove_after_x_steps:
			collided_penguins.erase(penguin)
		else:
			collided_penguins[penguin] += 1

func on_penguin_collision(penguin):
	if not penguin in collided_penguins:
		collided_penguins[penguin] = 0
		var n_spawn = (randi() % max_fish_spawn) + 1
		for i in range(n_spawn):
			_spawn_fish()
		penguin.ai.after_bucket_collision()
	else:
		return

func _spawn_fish():
	var new_fish = fish_scene.instance() as Fish
	var x = (randi() % fish_spawn_offset) - half_fish_spawn_offset
	var y = (randi() % fish_spawn_offset) - half_fish_spawn_offset
	var random_impulse = Vector2(x, y)
	new_fish.position = (random_impulse)
	add_child(new_fish)
