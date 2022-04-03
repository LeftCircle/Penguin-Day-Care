extends RigidBody2D
class_name Fish

export(int, 0, 120) var min_lifetime = 45
export(int, 0, 200) var impulse_force = 50

var alive_frames = 0

func _ready():
	add_to_group("Fish")

func get_class():
	return "Fish"

func _physics_process(delta):
	alive_frames += 1
	var colliding_bodies = get_colliding_bodies()
	if alive_frames > min_lifetime:
		for body in colliding_bodies:
			if body.get_class() == "Penguin":
				_push_away_from(body)

func _on_Fish_body_entered(body):
	if alive_frames < min_lifetime:
		_push_away_from(body)
		return
	if body.get_class() == "Penguin":
		queue_free()
		(body).on_fish_collision()

func _push_away_from(body):
	var vec = global_position.direction_to(body.global_position)
	apply_central_impulse(-vec * impulse_force)
