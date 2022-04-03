extends Sprite
class_name SwimPoint


func _ready():
	add_to_group("SwimPoint")
	visible = false

func get_class():
	return "SwimPoint"
