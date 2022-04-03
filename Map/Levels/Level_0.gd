extends Node
class_name Level

onready var land_nav = $LandNav
onready var water_nav = $WaterNav

func _ready():
	GlobalFunctions.land_nav = land_nav
	GlobalFunctions.water_nav = water_nav
