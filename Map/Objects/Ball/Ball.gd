extends RigidBody2D
class_name Ball

export(int, 0, 200) var impulse_force = 50

enum {SELECTED, FREE}
var state = FREE

onready var collision = $CollisionShape2D

func _ready():
	add_to_group("Ball")

func get_class():
	return "Ball"

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_action_pressed("pick_up"):
			state = SELECTED
			set_collisions(false)
		if event.button_index == BUTTON_LEFT and event.is_action_released("pick_up"):
			state = FREE
			set_collisions(true)

func set_collisions(to_enable : bool):
	set_collision_layer_bit(20, !to_enable)
	set_collision_layer_bit(2, to_enable)
	set_collision_mask_bit(0, to_enable)
	set_collision_mask_bit(1, to_enable)
	set_collision_mask_bit(2, to_enable)
	

func _physics_process(delta):
	if state == SELECTED:
		drag_to_mouse_position()
		linear_velocity = Vector2.ZERO
	if GlobalFunctions.is_in_water(global_position):
		linear_damp = 5
	else:
		linear_damp = 0.5

func drag_to_mouse_position():
	var mousepos = get_global_mouse_position()
	global_transform.origin = mousepos


func _on_Ball_body_entered(body):
	_push_away_from(body)
	if body.get_class() == "Penguin":
		(body).on_ball_collision(self)

func _push_away_from(body):
	var vec = global_position.direction_to(body.global_position)
	apply_central_impulse(-vec * impulse_force)
