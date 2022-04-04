extends Control
class_name PenguinHandler

export(int, 0, 50) var n_penguins = 16
export(int, 0, 50) var must_survive = 8
export(int, 10, 60) var time_limit = 30


signal success
signal failure

onready var deaths_to_delay = n_penguins - must_survive
onready var penguin_container = $PenguinContainer
onready var time = $Labels/Time
onready var death_limit = $Labels/DeathLimitLabel
onready var deaths = $Labels/Deaths

#var physics_delay = 10

func _ready():
	_spawn_penguins()
	time.text = str(time_limit)
	death_limit.text = "Delay " + str(deaths_to_delay) + " Deaths"

func _physics_process(delta):
#	physics_delay -= 1
#	if physics_delay < 0:
	_check_for_loss()
	_check_for_win()
	_update_deaths()

func _check_for_loss():
	if get_n_penguins() <= must_survive:
		queue_free()
		emit_signal("failure")
		print("FAIL!")

func _check_for_win():
	if time_limit <= 0:
		queue_free()
		emit_signal("success")
		print("SUCCESS")

func _update_deaths():
	deaths.text = str(n_penguins - penguin_container.get_child_count())

func get_n_penguins():
	return penguin_container.get_child_count()

func _spawn_penguins():
	var spawners = $Spawners.get_children()
	for i in range(n_penguins):
		var spawner = spawners[randi() % spawners.size()] as PenguinSpawner
		spawner.spawn_penguin(penguin_container)


func _on_SecondTimer_timeout():
	time_limit -= 1
	time.text = str(time_limit)
	
