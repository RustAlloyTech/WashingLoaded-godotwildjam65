extends Node

signal signal_clean_cloth_ready_for_pickup(cloth:Cloth)
signal signal_clean_cloth_yoinked(cloth:Cloth)
#singal.... oh no, anyway i dont trust i can rename without error
signal signal_point_increased(points : int)
signal signal_customer_arrived
signal signal_customer_left

signal signal_energy_usage_changed
signal signal_power_down
signal signal_power_up

signal signal_electric_switch_turned_on
signal signal_electric_switch_turned_off

signal signal_back_to_main_menu_button_pressed
signal signal_try_again_button_pressed
signal signal_next_level_button_pressed

var current_level = 1
var level_max_scores = [0,0,0,0,0,0,0,0,0,0]
var level_max_stars  = [0,0,0,0,0,0,0,0,0,0]

func save():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var json_string = JSON.stringify({
		"scores" : level_max_scores,
		"stars" : level_max_stars
	})

	save_game.store_line(json_string)
	print("game should be saved now")
	save_game.close()


func _ready():
	if not FileAccess.file_exists("user://savegame.save"):
		print("no savefile yet") # Error! We don't have a save to load.
		return
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return

		var score_data = json.get_data()
		print (score_data)
		if score_data["scores"] != null:
			level_max_scores = score_data["scores"]
			
		if score_data["stars"] != null:
			level_max_stars = score_data["stars"]

	
