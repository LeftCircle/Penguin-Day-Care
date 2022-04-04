extends KinematicBody2D
class_name Penguin

export(int, 0, 250) var max_wander_speed = 45
export(int, 0, 250) var max_interest_speed = 120
export(int, 0, 250) var impulse_speed = 250
export(int, 0, 10) var max_fish_in_stomach = 3


enum {SEARCH, EATING_FISH, KICKING_BALL, FIGHTING, BURSTING, BEING_EATEN}

var fish_in_stomach = 0
var acceleration = 1000
var velocity = Vector2.ZERO
# Points towards where the penguin wants to go
var looking_vector = Vector2.ZERO
var collision_impulse = Vector2.ZERO
var impulse_decay = 200
var penguin_state = SEARCH

onready var desires = $AnimationSprites/Desire
onready var animations = $AnimationPlayer
onready var ai = $PenguinAI
onready var particles = $Particles2D

func _ready():
	for sprite in $AnimationSprites.get_children():
		sprite.visible = false
	add_to_group("Penguin")
	$DigestionTimer.connect("timeout", self, "_on_digestion_timer_end")

func get_class():
	return "Penguin"

func _physics_process(delta):
	food_scale()
	if GlobalFunctions.is_in_water(global_position):
		if not is_in_group("PenguinInWater"):
			add_to_group("PenguinInWater")
	else:
		if is_in_group("PenguinInWater"):
			remove_from_group("PenguinInWater")
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
	if GlobalFunctions.is_in_water(global_position):
		animations.play("SwimIdle")
	else:
		animations.play("Idle")
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	_move_slide_and_collide()

func _move(delta):
	if GlobalFunctions.is_in_water(global_position):
		animations.play("SlideDown")
	else:
		animations.play("WalkDown")
	var max_speed = max_wander_speed if ai.current_state == ai.states.WANDER else max_interest_speed
	velocity = velocity.move_toward(looking_vector * max_speed, acceleration * delta)
	if velocity.length_squared() > pow(max_speed, 2):
		velocity = velocity.normalized() * max_speed
	_move_slide_and_collide()


func _on_collision_impulse(delta):
	collision_impulse = collision_impulse.move_toward(Vector2.ZERO, impulse_decay * delta)
	velocity = collision_impulse
	move_and_slide(velocity, Vector2.ZERO, 4, PI / 4, false)

# Performs the move and slide and looks for specific collisions
func _move_slide_and_collide() -> void:
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider
		_on_collision(collider)

func _on_collision(collider : Object) -> void:
	if collider.get_class() != "Fish":
		if not collider == ai.desired_object:
			apply_impulse()
	if collider.is_in_group("BucketOfFish"):
		(collider as BucketOfFish).on_penguin_collision(self)
	elif collider.is_in_group("Penguin"):
		on_penguin_collision(collider)
	elif collider.is_in_group("Shark"):
		_on_shark_collision()

func on_fish_collision():
	penguin_state = EATING_FISH
	animations.play("EatingFish")

func on_fish_early_collision(fish):
	var vec_to_pen = global_position.direction_to(fish.global_position)
	collision_impulse = - vec_to_pen * impulse_speed
	velocity = collision_impulse

func on_penguin_collision(penguin : Penguin):
	var vec_to_pen = global_position.direction_to(penguin.global_position)
	collision_impulse = - vec_to_pen * impulse_speed
	velocity = collision_impulse

func on_ball_collision(ball : Ball) -> void:
	var vec_to_ball = ball.global_position.direction_to(self.global_position)
	collision_impulse = vec_to_ball * 0.5 *  impulse_speed
	velocity = collision_impulse
	ai.n_kicks += 1
	#print(ai.n_kicks)
	ai.time_since_kick = 0

func _on_shark_collision():
	queue_free()

func apply_impulse():
	# Applay an impulse opposite +/- 45 degrees from the looking vector
	var r_degrees = 65 if randi() % 2 == 0 else -65
	collision_impulse = -looking_vector.rotated(deg2rad(r_degrees)) * impulse_speed
	velocity = collision_impulse

func _on_finished_eating_fish():
	penguin_state = SEARCH
	fish_in_stomach += 1
	if fish_in_stomach >= max_fish_in_stomach:
		on_death()
	ai.after_eating_fish()

func _on_digestion_timer_end():
	#print("Digested")
	fish_in_stomach -= 1
	fish_in_stomach = max(0, fish_in_stomach)

func food_scale():
	var scale_increase = 0.5 * fish_in_stomach
	scale = Vector2.ONE * scale_increase + Vector2.ONE

func on_death():
	set_physics_process(false)
	animations.play("Pop")

func show_desire(desire : String):
	if desire == "swim":
		desires.show()
		desires.frame = 0
	elif desire == "fish":
		desires.show()
		desires.frame = 8
	elif desire == "ball":
		desires.show()
		desires.frame = 12
	else:
		desires.hide()
