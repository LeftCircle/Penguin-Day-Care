extends Control
class_name HomeScreen

export(int, 0, 360) var fade_time = 60
export(int, 0, 360) var fade_after = 180

var fade_timer = 0
var wait_timer = 0

enum {FADING, REAPEARING, WAITING}
var state = WAITING
var alpha_value = 1

signal start_game

onready var text = $SpaceToStart
onready var timer = $FadeAnimation/StartFade
onready var animation = $FadeAnimation/AnimationPlayer

func _ready():
	timer.connect("timeout", self, "_on_fade_timeout")
	timer.start()

func _physics_process(delta):
	_check_for_game_start()

func _on_fade_timeout():
	animation.play("FadeText")

func _on_animation_end():
	timer.start()

func _check_for_game_start():
	if Input.is_action_just_pressed("start_game"):
		print("Start the game!")
		queue_free()
		emit_signal("start_game")

#func _physics_process(delta):
#	if state == WAITING:
#		if wait_timer == fade_after:
#			state = FADING
#			wait_timer = 0
#		else:
#			wait_timer += 1
#	elif state == FADING:
#		if fade
#		alpha_value = (fade_time - fade_timer)
