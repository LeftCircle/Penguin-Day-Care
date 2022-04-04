extends Node2D

signal intro_ended

func _ready():
	$IntroRules.play("IntroRules")

func _physics_process(delta):
	if Input.is_action_just_pressed("start_game"):
		_on_intro_ended()

func _on_intro_ended():
	queue_free()
	emit_signal("intro_ended")
	
