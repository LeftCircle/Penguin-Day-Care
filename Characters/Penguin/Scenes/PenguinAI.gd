extends Node
class_name PenguinAI

export(float, 0, 1) var switch_state_chance = 0.05
export(int, 150, 500) var max_sight = 500
export(int, 100, 500) var max_wandar_distance = 100
export(float, 0, 1) var desire_threshold = 0.9
export(float, 0, 150) var desire_distance = 150

enum states{SWIM, GO_FOR_BUCKET, EAT, BALL, SLIDE, FIGHT, WANDER, N_STATES}

var current_state = states.GO_FOR_BUCKET
var previous_state = states.WANDER
var wander_looking_vec : Vector2

var swim : float = 0
var bucket : float = 0
var eat_desire : float = 0
var ball_desire : float = 0
var slide : float = 0
var fight : float = 0
var wander : float = 0.1

var desired_object = null
var wander_position = Vector2.INF

onready var desire_sq_dist = pow(desire_distance, 2)
onready var half_max_wander = max_wandar_distance / 2

func _init():
	randomize()
	wander_looking_vec.x = randf() - 0.5
	wander_looking_vec.y = randf() - 0.5

func _switch_state(new_state : int) -> void:
	if new_state != current_state:
		previous_state = current_state
		current_state = new_state

func get_looking_vector_and_set_state(current_position : Vector2) -> Vector2:
	_check_for_state_switch(current_position)
	if current_state == states.WANDER:
		return _on_wandar_state(current_position)
	elif current_state == states.GO_FOR_BUCKET:
		return _on_bucket_state(current_position)
	elif current_state == states.EAT:
		return _on_eat_state(current_position)
	else:
		current_state = states.WANDER
	return Vector2.ZERO

func _check_for_state_switch(current_position : Vector2):
	# See if there is a ball or fish nearby (or check for weight desires?)
	var desired_ball = _get_desired_ball_or_null(current_position)
	if desired_ball != null:
		desired_object = desired_ball
		return
	var desired_fish = _get_desired_fish_or_null(current_position)
	if desired_fish != null:
		#print("Eat desire = ", eat_desire)
		desired_object = desired_fish
		_switch_state(states.EAT)
		

func _get_desired_ball_or_null(current_position : Vector2):
	var balls = get_tree().get_nodes_in_group("Ball")
	var closest_ball = null
	var min_dist_sq = INF
	ball_desire = 0
	for ball in balls:
		var dist_sq = current_position.distance_squared_to(ball.global_position)
		if dist_sq < 0.1:
			return ball
		if dist_sq <= desire_sq_dist:
			var desire_percent = 1 - (dist_sq / desire_sq_dist)
			ball_desire += desire_percent
		if dist_sq < min_dist_sq:
			closest_ball = ball
			min_dist_sq = dist_sq
	if ball_desire > desire_threshold:
		return closest_ball
	return null

func _get_desired_fish_or_null(current_position : Vector2):
	if previous_state == states.GO_FOR_BUCKET or current_state == states.GO_FOR_BUCKET:
		return null
	var closest_fish = null
	var all_fish = get_tree().get_nodes_in_group("Fish")
	var min_distance_sq = INF
	eat_desire = 0
	for fish in all_fish:
		var dist_sq = current_position.distance_squared_to(fish.global_position)
		if dist_sq < 0.1:
			return fish
		if dist_sq < desire_sq_dist:
			var desire_percent = 1 - (dist_sq / desire_sq_dist)
			eat_desire += get_desire(desire_percent)
		if dist_sq < min_distance_sq:
			closest_fish = fish
			min_distance_sq = dist_sq
	if eat_desire > desire_threshold:
		return closest_fish
	return null

func _on_wandar_state(current_position : Vector2) -> Vector2:
	if randf() < switch_state_chance:
		current_state = randi() % states.N_STATES
		previous_state = states.WANDER
		wander_position = Vector2.INF
	if wander_position == Vector2.INF:
		if randf() < 0.01:
			wander_position.x = current_position.x + (randi() % max_wandar_distance) - half_max_wander
			wander_position.y = current_position.y + (randi() % max_wandar_distance) - half_max_wander
			wander_looking_vec = current_position.direction_to(wander_position)
			print("Wandering to ", wander_position, " from ", current_position)
		else:
			wander_position = current_position
			wander_looking_vec = Vector2.ZERO
	if current_position.distance_squared_to(wander_position) < 25:
		wander_position = Vector2.INF
		return Vector2.ZERO
	return wander_looking_vec

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
	if desired_object != null and is_instance_valid(desired_object):
		if desired_object.get_class() == "Fish":
			return current_position.direction_to(desired_object.global_position)
	else:
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
		desired_object = null
		print("Setting state to eat")

func after_eating_fish():
	if previous_state == states.GO_FOR_BUCKET:
		current_state = states.GO_FOR_BUCKET
	else:
		current_state = states.WANDER
	desired_object = null
	previous_state = states.EAT

func get_desire(percent : float):
	assert(0 < percent and percent <= 1)
	var desire = (0.1 / percent) - 0.1
	desire = clamp(desire, 0, 1)
	#print("Desire = ", desire)
	return desire
