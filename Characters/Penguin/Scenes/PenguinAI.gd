extends Node
class_name PenguinAI

export(float, 0, 1) var switch_state_chance = 0.05
export(int, 150, 500) var max_sight = 500

enum states{SWIM, GO_FOR_BUCKET, EAT, BALL, SLIDE, FIGHT, WANDER, N_STATES}

var current_state = states.GO_FOR_BUCKET
var previous_state = states.WANDER

var swim : float = 0
var bucket : float = 0
var eat : float = 0
var ball : float = 0
var slide : float = 0
var fight : float = 0
var wander : float = 0.1

var desired_object = null

func _init():
	randomize()

func get_looking_vector_and_set_state(current_position : Vector2) -> Vector2:
	_check_for_state_switch()
	if current_state == states.WANDER:
		return _on_wandar_state(current_position)
	elif current_state == states.GO_FOR_BUCKET:
		return _on_bucket_state(current_position)
	elif current_state == states.EAT:
		return _on_eat_state(current_position)
	return Vector2.ZERO

func _check_for_state_switch():
	# See if there is a ball or fish nearby (or check for weight desires?)
	pass

func _on_wandar_state(current_position) -> Vector2:
	# Could start walking towards areas of interest such as groups of penguins or something
	if randf() < switch_state_chance:
		# This still allows the penguin to continue to wander
		current_state = randi() % states.N_STATES
		previous_state = states.WANDER
	return Vector2.ZERO

func _on_bucket_state(current_position : Vector2) -> Vector2:
	if desired_object == null:
		desired_object = GlobalFunctions.get_random_object_in_group("BucketOfFish")
	if typeof(desired_object) == TYPE_INT and desired_object == GlobalFunctions.errors.NO_OBJECTS_IN_GROUP:
		# Try to eat, but break the cycle by setting the previous state to wandar
		current_state = states.EAT
		previous_state = states.WANDER
		desired_object = null
		return Vector2.ZERO
	var looking_vec = current_position.direction_to(desired_object.global_position)
	return looking_vec

func _on_eat_state(current_position : Vector2) -> Vector2:
		# If there is food within range, go towards the food. If not, check the previous
	# state. If previous state is BUCKET, then state == Bucket else Wander
	var closest_fish = null
	var all_fish = get_tree().get_nodes_in_group("Fish")
	var min_distance_sq = INF
	for fish in all_fish:
		var distance_sq_to = current_position.distance_squared_to(fish.global_position)
		if distance_sq_to < min_distance_sq:
			min_distance_sq = distance_sq_to
			closest_fish = fish
	if min_distance_sq <= pow(max_sight, 2):
		desired_object = closest_fish
	else:
		if previous_state == states.GO_FOR_BUCKET:
			current_state = states.GO_FOR_BUCKET
		else:
			current_state = states.WANDER
		desired_object = null
		return Vector2.ZERO
	return current_position.direction_to(desired_object.global_position)

func _on_ball(current_position : Vector2) -> Vector2:
	# Go towards the nearest ball
	return Vector2.ZERO

func _on_slide(current_position : Vector2) -> Vector2:
	# Go towards one of the three slides
	return Vector2.ZERO

func _on_fight(current_position : Vector2) -> Vector2:
	# Fight the nearest penguin!
	return Vector2.ZERO

func _on_swim(current_position : Vector2) -> Vector2:
	# Pick a random point in the water
	return Vector2.ZERO

func after_bucket_collision():
	if current_state == states.GO_FOR_BUCKET:
		previous_state = current_state
		current_state = states.EAT
