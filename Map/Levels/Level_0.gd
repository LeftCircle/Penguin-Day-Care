extends Node
class_name Level

onready var land_nav = $LandNav
onready var water_nav = $WaterNav

signal success
signal failure

func _ready():
	GlobalFunctions.land_nav = land_nav
	GlobalFunctions.water_nav = water_nav
	randomize()
	$PenguinHandler.connect("success", self, "_on_success")
	$PenguinHandler.connect("failure", self, "_on_failure")

func _on_success():
	queue_free()
	emit_signal("success")

func _on_failure():
	queue_free()
	emit_signal("failure")
