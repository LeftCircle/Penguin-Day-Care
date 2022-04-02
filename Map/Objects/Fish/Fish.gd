extends RigidBody2D
class_name Fish

func _ready():
	add_to_group("Fish")

func get_class():
	return "Fish"


func _on_Fish_body_entered(body):
	print("Entered by " + body.get_class())
