extends KinematicBody2D
class_name Shark

var roam_point = null
var penguin_to_eat : Penguin
var roam_speed = 45
var hunt_speed = 65
var acceleration = 50
var looking_vector = Vector2.ZERO
var velocity = Vector2.ZERO

var current_path = []

onready var animations = $AnimationPlayer

func _ready():
	add_to_group("Shark")

func get_class():
	return "Shark"

func _physics_process(delta):
	if penguin_to_eat == null:
		_search_for_penguins()
		_on_roam(delta)
	else:
		pass

func _search_for_penguins():
	if not get_tree().get_nodes_in_group("PenguinInWater").empty():
		penguin_to_eat = GlobalFunctions.get_random_object_in_group("PenguinInWater")
		animations.play("SwimUpRightSensing")

func _on_roam(delta):
	if current_path.empty():
		roam_point = get_roam_point()
		current_path = GlobalFunctions.water_nav.get_simple_path(global_position, roam_point.global_position)
		current_path = Array(current_path)
	looking_vector = global_position.direction_to(current_path[0])
	if global_position.distance_squared_to(current_path[0]) < 1:
		current_path.pop_front()
	velocity = velocity.move_toward(looking_vector * roam_speed, acceleration * delta)
	velocity = move_and_slide(velocity)
	_play_swim()

func _while_hunting(delta : float):
	if not penguin_to_eat.is_in_group("PenguinInWater"):
		penguin_to_eat = null
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	else:
		looking_vector = penguin_to_eat.global_position
		velocity = velocity.move_toward(looking_vector * hunt_speed, acceleration * delta)
	_play_swim()

func _play_swim():
	if not animations.current_animation == "SwimUpRightSensing":
		animations.play("SwimUpRight")
	self.rotation_degrees = rad2deg(looking_vector.angle())

func get_roam_point():
	return GlobalFunctions.get_random_object_in_group("SwimPoint")

