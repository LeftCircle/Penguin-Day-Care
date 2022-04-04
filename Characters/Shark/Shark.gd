extends KinematicBody2D
class_name Shark

var roam_point = null
var penguin_to_eat : Penguin
var roam_speed = 65
var hunt_speed = 150
var acceleration = 75
var looking_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var sightline_sq = pow(300, 2)

var current_path = []
var hunt_path = []

onready var animations = $AnimationPlayer
onready var collisions = $CollisionShape2D

func _ready():
	add_to_group("Shark")

func get_class():
	return "Shark"

func _physics_process(delta):
	if GlobalFunctions.is_in_water(global_position):
		if collisions.disabled:
			collisions.set_deferred("disabled", false)
	else:
		if not collisions.disabled:
			collisions.set_deferred("disabled", true)
	if penguin_to_eat == null:
		_search_for_penguins()
		_on_roam(delta)
	else:
		_while_hunting(delta)

func _search_for_penguins():
	if not get_tree().get_nodes_in_group("PenguinInWater").empty():
		penguin_to_eat = GlobalFunctions.get_random_object_in_group("PenguinInWater")
		animations.play("SwimUpRightSensing")
		hunt_path = GlobalFunctions.water_nav.get_simple_path(global_position, penguin_to_eat.global_position)
		hunt_path = Array(hunt_path)

func _on_roam(delta):
	if current_path.empty():
		roam_point = get_roam_point()
		current_path = GlobalFunctions.water_nav.get_simple_path(global_position, roam_point.global_position)
		current_path = Array(current_path)
	looking_vector = global_position.direction_to(current_path[0])
	if global_position.distance_squared_to(current_path[0]) < 1:
		current_path.pop_front()
	velocity = velocity.move_toward(looking_vector * roam_speed, acceleration * delta)
	velocity = _move_slide_and_collide(velocity)
	_play_swim()

func _while_hunting(delta : float):
	if not is_instance_valid(penguin_to_eat) or not penguin_to_eat.is_in_group("PenguinInWater"):
		penguin_to_eat = null
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	else:
		#if global_position.distance_squared_to(penguin_to_eat.global_position) < sightline_sq:
		looking_vector = global_position.direction_to(penguin_to_eat.global_position)
		velocity = velocity.move_toward(looking_vector * hunt_speed, acceleration * delta)
	velocity = _move_slide_and_collide(velocity)
#		else:
#			if not hunt_path.empty():
#				looking_vector = global_position.direction_to(hunt_path[0])
#				if global_position.distance_squared_to(hunt_path[0]) < 1:
#					current_path.pop_front()
#				velocity = velocity.move_toward(looking_vector * hunt_speed, acceleration * delta)
#				velocity = move_and_slide(velocity)
	_play_swim()

func _play_swim():
	if not animations.current_animation == "SwimUpRightSensing":
		animations.play("SwimUpRight")
	self.rotation_degrees = rad2deg(looking_vector.angle())

func get_roam_point():
	return GlobalFunctions.get_random_object_in_group("SwimPoint")

func _move_slide_and_collide(velocity) -> Vector2:
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider
		_on_collision(collider)
	return velocity

func _on_collision(collider):
	if collider.is_in_group("PenguinInWater"):
		collider.on_death()
