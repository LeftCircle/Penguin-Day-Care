extends Node
class_name PenguinAI

export(float, 0, 1) var switch_state_chance = 0.2

enum states{SWIM, EAT, BALL, SLIDE, FIGHT, WANDER, N_STATES}
var current_state = states.WANDER


var swim : float = 0
var eat : float = 0
var ball : float = 0
var slide : float = 0
var fight : float = 0
var wander : float = 0.1

func _ready():
	randomize()

# Chance to switch to another state if we are wandering
func set_state_after_wander() -> void:
	if randf() < switch_state_chance:
		# This still allows the penguin to continue to wander
		current_state = randi() % states.N_STATES
