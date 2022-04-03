extends ParallaxBackground


onready var land_nav = $LandNav
onready var water_nav = $WaterNav
onready var dummy = $Dummy
onready var dummy2 = $Dummy2


func _ready():
	print(dummy.global_position, " ", dummy2.global_position)
	print(is_on_land(dummy.global_position), " ", is_on_land(dummy2.global_position))
	path_to_land_point(dummy.global_position, dummy2.global_position)

func path_to_land_point(start : Vector2, end : Vector2):
	var path = land_nav.get_simple_path(start, end)
	print("Land path = ", path)
	return path

func is_on_land(point : Vector2):
	return land_nav.get_closest_point(point).distance_squared_to(point) < 1
	
