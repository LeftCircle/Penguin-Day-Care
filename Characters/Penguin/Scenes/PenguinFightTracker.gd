extends Node

export(int, 3, 10) var bumps_before_fight
export(int, 1, 10) var bumps_before_kill
export(int, 30, 360) var bump_lifetime = 60

var bump_history = {}
var murder_queue = []
var fight_in_progress = false
var currently_fighting = null

signal time_to_fight(penguin)

func _physics_process(delta):
	if not murder_queue.empty():
		if not fight_in_progress:
			currently_fighting = murder_queue.pop_front()
			fight_in_progress = true
	# Remove a bump after a short time
	for penguin in bump_history:
		pass

func on_bump(penguin : Penguin):
	if not penguin in bump_history:
		bump_history[penguin] = {
			"BumpNumber" : 1,
			"Timer" : 0
		}
	else:
		bump_history[penguin]["BumpNumber"] += 1
		if bump_history[penguin]["BumpNumber"] > bumps_before_fight:
			if not penguin in murder_queue:
				murder_queue.append(penguin)

func on_fight_ended():
	pass
	# If the murder_history is empty, start to wandar. Otherwise RAGE
	
