extends Node2D

export(PackedScene) var home_screen_scene
export(PackedScene) var intro_scene
export(PackedScene) var level_0_scene
export(PackedScene) var end_scene

var home_screen : HomeScreen
var level
var intro
var end

func _ready():
	$StudioIntro.connect("look_left_intro_ended", self, "_on_look_left_intro_ended_ended")

func _on_look_left_intro_ended_ended():
	$StudioIntro.queue_free()
	_go_to_home_screen()

func _go_to_home_screen():
	home_screen = home_screen_scene.instance()
	add_child(home_screen)
	home_screen.connect("start_game", self, "_on_start_intro")

func _on_start_intro():
	intro = intro_scene.instance()
	add_child(intro)
	intro.connect("intro_ended", self, "_on_start_level")

func _on_start_level():
	if is_instance_valid(intro):
		intro.queue_free()
	level = level_0_scene.instance()
	level.connect("failure", self, "_on_failure")
	level.connect("success", self, "_on_success")
	add_child(level)

func _on_failure():
	end = end_scene.instance()
	end.init("failure")
	end.connect("restart", self, "_on_restart")
	add_child(end)

func _on_success():
	end = end_scene.instance()
	end.init("success")
	end.connect("restart", self, "_on_restart")
	add_child(end)

func _on_restart():
	_go_to_home_screen()
