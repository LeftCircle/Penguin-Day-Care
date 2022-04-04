extends Node2D

signal look_left_intro_ended

func _ready():
	$LookLeftStudio.play("Intro")


func _on_intro_ended():
	queue_free()
	emit_signal("look_left_intro_ended")
