extends KinematicBody2D
class_name Penguin

export(int, 0, 250) var max_speed = 45
export(int, 0, 250) var impulse_speed = 100

enum {SEARCH, EATING_FISH, KICKING_BALL, FIGHTING, BURSTING, BEING_EATEN}

var acceleration = 1000
var velocity = Vector2.ZERO
# Points towards where the penguin wants to go
var looking_vector = Vector2.ZERO
var collision_impulse = Vector2.ZERO
var impulse_decay = 200
var penguin_state = SEARCH


onready var animations = $AnimationPlayer
onready var ai = $PenguinAI

func _ready():
	add_to_group("Penguin")

func get_class():
	return "Penguin"

func _physics_process(delta):
	if penguin_state == SEARCH:
		looking_vector = ai.get_looking_vector_and_set_state(self.global_position)
		if collision_impulse != Vector2.ZERO:
			_on_collision_impulse(delta)
		if looking_vector == Vector2.ZERO:
			_idle(delta)
		else:
			_move(delta)
	elif penguin_state == EATING_FISH:
		animations.play("EatingFish")

func _idle(delta):
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	_move_slide_and_collide()

func _move(delta):
	velocity = velocity.move_toward(looking_vector * max_speed, acceleration * delta)
	if velocity.length_squared() > pow(max_speed, 2):
		velocity = velocity.normalized() * max_speed
	_move_slide_and_collide()

func _on_collision_impulse(delta):
	collision_impulse = collision_impulse.move_toward(Vector2.ZERO, impulse_decay * delta)
	velocity = collision_impulse
	move_and_slide(velocity)

# Performs the move and slide and looks for specific collisions
func _move_slide_and_collide() -> void:
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.collider.name)
		var collider = collision.collider
		_on_collision(collider)
		if collider.get_class() == "Ball":
			break
		elif collider.get_class() == "Fish":
			break

func _on_collision(collider : Object) -> void:
	if collider.get_class() != "Fish":
		if not collider == ai.desired_object:
			apply_impulse()
	if collider.is_in_group("BucketOfFish"):
		(collider as BucketOfFish).on_penguin_collision(self)
	elif collider.is_in_group("Fish"):
		_on_fish_collision(collider)

func _on_fish_collision(fish):
	print("Collided with fish " + fish.name)

func apply_impulse():
	# Applay an impulse opposite +/- 45 degrees from the looking vector
	var r_degrees = 45 if randi() % 2 == 0 else -45
	collision_impulse = -looking_vector.rotated(deg2rad(r_degrees)) * impulse_speed
	velocity = collision_impulse

func _on_finished_eating_fish():
	penguin_state = SEARCH
