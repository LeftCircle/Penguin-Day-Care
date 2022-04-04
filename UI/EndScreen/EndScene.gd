extends Node2D


signal restart

func init(status : String) -> void:
	if status == "success":
		$Success.show()
		$Failure.hide()
	else:
		$Success.hide()
		$Failure.show()

func _physics_process(delta):
	if Input.is_action_just_pressed("start_game"):
		queue_free()
		emit_signal("restart")
