extends Node
class_name PenguinAI

export(float, 0, 1) var switch_state_chance = 0.05
export(int, 150, 500) var max_sight = 500
export(int, 100, 5000) var max_wandar_distance = 2000
export(float, 0, 1) var desire_threshold = 0.87
export(float, 0, 350) var desire_distance = 350
export(int, 0, 600) var max_ball_chase = 180
export(int, 0, 5) var max_kicks = 3
export(float, 0, 1) var bucket_weight = 0.5
export(float, 0, 1) var swim_weight = 0.5
export(float, 0, 1) var ball_weight = 0.5
export(float, 0, 1) var eat_weight = 0.5
export(float, 0, 1) var wander_weight = 0.5
export(float, 0, 1) var bear_weight = 0.5

enum states{SWIM, GO_FOR_BUCKET, EAT, BALL, WANDER, BEAR, N_STATES}


var current_state = states.GO_FOR_BUCKET
var previous_state = states.WANDER
var wander_looking_vec : Vector2

var eat_desire : float = 0
var ball_desire : float = 0
var fight : float = 0
var time_since_kick = 0
var n_kicks = 0

var desired_object = null
var wander_position = Vector2.INF

onready var desire_sq_dist = pow(desire_distance, 2)
onready var half_max_wander = max_wandar_distance / 2

func _init():
	randomize()
	wander_looking_vec.x = randf() - 0.5
	wander_looking_vec.y = randf() - 0.5

func _physics_process(delta):
	# This is the main way of losing interest in the ball
	if current_state == states.BALL:
		if n_kicks >= max_kicks or time_since_kick > max_ball_chase:
			desired_object = null
			n_kicks = 0
			time_since_kick = 0
			_switch_state(states.WANDER)
		time_since_kick += 1

func _switch_state(new_state : int) -> void:
	if new_state != current_state:
		previous_state = current_state
		current_state = new_state

func get_looking_vector_and_set_state(current_position : Vector2) -> Vector2:
	_check_for_state_switch(current_position)
	#return Vector2.ZERO
	if current_state == states.WANDER:
		return _on_wandar_state(current_position)
	elif current_state == states.GO_FOR_BUCKET:
		return _on_bucket_state(current_position)
	elif current_state == states.EAT:
		return _on_eat_state(current_position)
	elif current_state == states.BALL:
		return _on_ball(current_position)
	elif current_state == states.SWIM:
		return _on_swim(current_position)
	else:
		current_state = states.WANDER
	return Vector2.ZERO

func _check_for_state_switch(current_position : Vector2):
	# See if there is a ball or fish nearby (or check for weight desires?)
	if desired_object == null or not is_instance_valid(desired_object) or desired_object.get_class() != "Ball":
		if not previous_state == states.BALL:
			var desired_ball = _get_desired_ball_or_null(current_position)
			if desired_ball != null:
				desired_object = desired_ball
				time_since_kick = 0
				n_kicks = 0
				_switch_state(states.BALL)
				return
	# We have to kick the ball once before eating fish
#	if is_instance_valid(desired_object) and desired_object.get_class() == "Ball":
#		if n_kicks < 1:
#			return
	var desired_fish = _get_desired_fish_or_null(current_position)
	if desired_fish != null:
		print("Desire dropped fish")
		desired_object = desired_fish
		_switch_state(states.EAT)


func _get_desired_ball_or_null(current_position : Vector2):
	var balls = get_tree().get_nodes_in_group("Ball")
	var closest_ball = null
	var min_dist_sq = INF
	ball_desire = 0
	for ball in balls:
		if ball.state == ball.SELECTED:
			continue
		var dist_sq = current_position.distance_squared_to(ball.global_position)
		if dist_sq < 1:
			return ball
		if dist_sq <= desire_sq_dist:
			var desire_percent = 1 - (dist_sq / desire_sq_dist)
			ball_desire += desire_percent
		if dist_sq < min_dist_sq:
			closest_ball = ball
			min_dist_sq = dist_sq
	#print(ball_desire)
	if ball_desire > desire_threshold:
		return closest_ball
	return null

func _get_desired_fish_or_null(current_position : Vector2):
	if previous_state == states.GO_FOR_BUCKET or current_state == states.GO_FOR_BUCKET:
		return null
	var closest_fish = null
	var all_fish = get_tree().get_nodes_in_group("DroppedFish")
	var min_distance_sq = INF
	eat_desire = 0
	for fish in all_fish:
		var dist_sq = current_position.distance_squared_to(fish.global_position)
		if dist_sq < 1:
			return fish
		if dist_sq < desire_sq_dist:
			var desire_percent = 1 - (dist_sq / desire_sq_dist)
			eat_desire += desire_percent
		if dist_sq < min_distance_sq:
			closest_fish = fish
			min_distance_sq = dist_sq
	#print(eat_desire)
	if eat_desire > desire_threshold:
		return closest_fish
	return null

func _on_wandar_state(current_position : Vector2) -> Vector2:
	if randf() < switch_state_chance:
		if not GlobalFunctions.is_in_water(current_position):
			pick_random_state()
			wander_position = Vector2.INF
	if wander_position == Vector2.INF:
		if randf() < 0.01:
			wander_position.x = current_position.x + (randi() % max_wandar_distance) - half_max_wander
			wander_position.y = current_position.y + (randi() % max_wandar_distance) - half_max_wander
			wander_looking_vec = current_position.direction_to(wander_position)
			if not GlobalFunctions.is_in_water(wander_position) or not GlobalFunctions.is_on_land(wander_position):
				wander_position = GlobalFunctions.get_random_object_in_group("Penguin").global_position
		else:
			wander_position = current_position
			wander_looking_vec = Vector2.ZERO
	if current_position.distance_squared_to(wander_position) < 25:
		wander_position = Vector2.INF
		return Vector2.ZERO
	return wander_looking_vec

func pick_random_state():
	var rand_state = {
		states.SWIM : randf() * swim_weight,
		states.WANDER : randf() * wander_weight,
		states.GO_FOR_BUCKET : randf() * bucket_weight,
		states.EAT : randf() * eat_weight,
		states.BALL : randf() * ball_weight,
		states.BEAR : randf() * bear_weight,
	}
	var max_val = 0
	var max_state = states.WANDER
	for state in rand_state:
		if rand_state[state] > max_val:
			max_val = rand_state[state]
			max_state = state
	#print("Picked max_state")
	_switch_state(max_state)

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
	if is_instance_valid(desired_object):
		if desired_object.get_class() == "Ball":
			return current_position.direction_to(desired_object.global_position)
	_switch_state(states.WANDER)
	return Vector2.ZERO

func _on_slide(current_position : Vector2) -> Vector2:
	# Go towards one of the three slides
	return Vector2.ZERO

func _on_fight(current_position : Vector2) -> Vector2:
	# Fight the nearest penguin!
	return Vector2.ZERO

func _on_swim(current_position : Vector2) -> Vector2:
	if is_instance_valid(desired_object) and desired_object.is_in_group("SwimPoint"):
		if current_position.distance_squared_to(desired_object.global_position) < 100:
			desired_object = null
			_switch_state(states.WANDER)
			return Vector2.ZERO 
	else:
		desired_object = GlobalFunctions.get_random_object_in_group("SwimPoint")
	return current_position.direction_to(desired_object.global_position)

func after_bucket_collision():
	if current_state == states.GO_FOR_BUCKET:
		previous_state = current_state
		current_state = states.EAT
		desired_object = null

func after_eating_fish():
	if previous_state == states.GO_FOR_BUCKET:
		current_state = states.GO_FOR_BUCKET
	elif previous_state == states.BALL:
		current_state = states.BALL
	else:
		current_state = states.WANDER
	desired_object = null
	previous_state = states.EAT

func get_desire(percent : float):
	assert(0 < percent and percent <= 1)
	var desire = (0.1 / percent) - 0.1
	desire = clamp(desire, 0, 1)
	return desire
