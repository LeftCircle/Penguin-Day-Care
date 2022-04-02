extends KinematicBody2D
class_name Penguin

export(int, 0, 1000) var max_speed
var acceleration = 1000
var velocity = Vector2.ZERO
# Points towards where the penguin wants to go
var looking_vector = Vector2.ZERO
var ai = PenguinAI.new()

func _ready():
	pass

func _physics_process(delta):
	if looking_vector == Vector2.ZERO:
		_idle(delta)
	else:
		_move(delta)

func _idle(delta):
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	velocity = move_and_slide(velocity)

func _move(delta):
	velocity = velocity.move_toward(looking_vector * max_speed, acceleration * delta)
	velocity = move_and_slide(velocity)
