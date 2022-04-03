extends RigidBody2D
class_name Fish

export(int, 0, 120) var min_lifetime = 45
export(int, 0, 200) var impulse_force = 50

enum {SELECTED, FREE}
var state = FREE

var alive_frames = 0

func _ready():
	add_to_group("Fish")

func get_class():
	return "Fish"

func _physics_process(delta):
	alive_frames += 1
	if state == SELECTED:
		drag_to_mouse_position()
		linear_velocity = Vector2.ZERO
	else:
		var colliding_bodies = get_colliding_bodies()
		if alive_frames > min_lifetime:
			for body in colliding_bodies:
				if body.get_class() == "Penguin":
					_push_away_from(body)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_action_pressed("pick_up"):
			state = SELECTED
			set_collisions(false)
		if event.button_index == BUTTON_LEFT and event.is_action_released("pick_up"):
			state = FREE
			set_collisions(true)
			add_to_group("DroppedFish")

func drag_to_mouse_position():
	var mousepos = get_global_mouse_position()
	global_transform.origin = mousepos

func _on_Fish_body_entered(body):
	if alive_frames < min_lifetime:
		if body.get_class() == "Penguin":
			body.on_fish_early_collision(self)
		_push_away_from(body)
		return
	if body.get_class() == "Penguin":
		queue_free()
		(body).on_fish_collision()

func _push_away_from(body):
	var vec = global_position.direction_to(body.global_position)
	apply_central_impulse(-vec * impulse_force)

func set_collisions(to_enable : bool):
	set_collision_layer_bit(20, !to_enable)
	set_collision_layer_bit(2, to_enable)
	set_collision_mask_bit(0, to_enable)
	set_collision_mask_bit(1, to_enable)
	set_collision_mask_bit(2, to_enable)
