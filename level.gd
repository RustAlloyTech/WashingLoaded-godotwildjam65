extends Node2D

@export var pointLabel : Label
@export var customer_spawner : CustomerSpawner

@onready var game_over_player = $"../GameOverPlayer"
@onready var level_flavor_text = $"../CanvasLayer2/LevelFlavorText"



const BANDAID = preload("res://Clothes/bandaid.tscn")

var star_1_score = 1000
var star_2_score = 2000
var star_3_score = 3000
var level_id = 1

#myscores
# level1: 3000
# level2: 6850
# level3: 9100
# level4: 19000
# level5: 14950


var score = 0
var start_time: float
var elapsed_time = 0.0

var level_spawn : Array[Array]

var customers_around = 0

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$"../CanvasLayer2".visible = true
	SignalBus.signal_point_increased.connect(_point_increase)
	SignalBus.signal_customer_arrived.connect(_customer_arrived)
	SignalBus.signal_customer_left.connect(_customer_left)
	
	SignalBus.signal_back_to_main_menu_button_pressed.connect(_on_exit_to_main_menu_butoon_pressed)
	SignalBus.signal_try_again_button_pressed.connect(_on_try_again_button_pressed)
	SignalBus.signal_next_level_button_pressed.connect(_on_next_level_button_pressed)
	
	level_id = SignalBus.current_level
	
	if level_id == 1:
		_level1()
	if level_id == 2:
		_level2()
	if level_id == 3:
		_level3()
	if level_id == 4:
		_level4()
	if level_id == 5:
		_level5()
	if level_id == 6:
		_level6()
	if level_id == 7:
		_level7()
	if level_id == 8:
		_level8()
	if level_id == 9:
		_level9()
	if level_id == 10:
		_level10()
		
	SignalBus.save()
	
	get_tree().paused = true
		
func _on_exit_to_main_menu_butoon_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_try_again_button_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_next_level_button_pressed():
	if SignalBus.current_level < 10:
		SignalBus.current_level += 1
		get_tree().change_scene_to_file("res://game.tscn")

func _customer_arrived():
	customers_around += 1
	
func _customer_left():
	customers_around -= 1
	if customers_around == 0:
		if level_spawn.size() > 0:
			var next_spawn = level_spawn[0]
			elapsed_time = next_spawn[0]

func _point_increase(points: int):
	score += points
	pointLabel.text = str(score)
	
func _level1():
	level_flavor_text.text = "\
	Day 1
	You just started your Dream job as a laundrymat owner
	Good Job!
	You have a humble shop, with one washing machine. 
	You do your best to be able to afford another one
	You don't expect too many customers Today." 
	$"../ElectricityShower".ready2(5)
	$"../WashingMachines/WashingMachine2".queue_free()
	$"../WashingMachines/WashingMachine3".queue_free()
	$"../WashingMachines/WashingMachine4".queue_free()
	
	
	$"../WashingMachines/WashingMachine"._draw_damage_look()
	
	Customer.wait_outside_min = 120
	Customer.wait_outside_max = 120
	
	level_spawn = [
		[0,"Shirt","Blue"],
		[15, "Jeans", "Blue"],
		[30,"Socks","Blue"]
	]
	
func _level2():
	level_flavor_text.text = "\
	Day 2
	You found a cheap used second machine for your shop
	It is Damaged, 
	so you need to use the Bandaid on the left
	to repair it!
	" 
	$"../ElectricityShower".ready2(10)
	$"../WashingMachines/WashingMachine".damage = 2
	$"../WashingMachines/WashingMachine"._draw_damage_look()
	
	$"../WashingMachines/WashingMachine3".queue_free()
	$"../WashingMachines/WashingMachine4".queue_free()
	
	star_1_score = 3500
	star_2_score = 6000
	star_3_score = 6500
	
	Customer.wait_outside_min = 45
	Customer.wait_outside_max = 45
	
	level_spawn = [
		[0,"Shirt","Blue"],
		[0,"Socks","Blue"],
		[30, "Any", "Blue"],
		[50,"Any","Blue"],
		[50,"Any","Blue"],
		[60,"Any","Blue"],
		[65,"Any","Blue"]
	]
	
func _level3():
	level_flavor_text.text = "\
	Day 3
	Red clothes are also incoming!
	If you want people to remain happy, 
	wash blue and red in different machines
	" 
	
	star_1_score = 5000
	star_2_score = 8000
	star_3_score = 10500
	
	Customer.wait_outside_min = 30
	Customer.wait_outside_max = 45
	
	$"../ElectricityShower".ready2(10)
	$"../WashingMachines/WashingMachine3".queue_free()
	$"../WashingMachines/WashingMachine4".queue_free()
	level_spawn = [
		[0,"Shirt","Blue"],
		[0,"Shirt","Red"],
		[12,"Shirt","Blue"],
		[15,"Shirt","Blue"],
		[20,"Any","Blue"],
		[25,"Any","Blue"],
		[29,"Any","Blue"],
		[55,"Any","Blue"],
		[60,"Any","Red"],
		[70,"Any","Blue"],
		[70,"Any","Blue"],
	]

func _level4():
	level_flavor_text.text = "\
	Day 4
	Angel Festival is in town! 
	Lot of people with white clothes incoming!
	" 
	
	star_1_score = 10000
	star_2_score = 15000
	star_3_score = 19000
	
	Customer.wait_outside_min = 30
	Customer.wait_outside_max = 60
	
	$"../ElectricityShower".ready2(10)
	$"../WashingMachines/WashingMachine3".queue_free()
	$"../WashingMachines/WashingMachine4".queue_free()
	level_spawn = [
		[0,"Shirt","White"],
		[0,"Shirt","White"],
		[0,"Socks","White"],
		[0,"Jeans","White"],
		[12,"Shirt","White"],
		[15,"Shirt","White"],
		[20,"Any","White"],
		[25,"Any","White"],
		[25,"Any","White"],
		[29,"Any","White"],
		[55,"Any","White"],
		[55,"Any","White"],
		[55,"Any","White"],
		[60,"Any","White"],
		[60,"Any","White"],
		[70,"Any","White"],
		[70,"Any","White"],
		[70,"Any","White"],
		[70,"Any","White"],
		[70,"Any","White"],
	]
	
	
func _level5():
	level_flavor_text.text = "\
	Day 5
	Your electricity is acting up!
	It cannot handle running both dryers
	If Electricity goes out,
	switch it back on with the switch on the right!
	" 
	
	star_1_score = 5000
	star_2_score = 7000
	star_3_score = 10500
	
	Customer.wait_outside_min = 30
	Customer.wait_outside_max = 60
	
	$"../ElectricityShower".ready2(9)
	$"../WashingMachines/WashingMachine3".queue_free()
	$"../WashingMachines/WashingMachine4".queue_free()
	level_spawn = [
		[0,"Shirt","Blue"],
		[0,"Shirt","Red"],
		[12,"Any","Red"],
		[15,"Any","Red"],
		[20,"Any","Blue"],
		[25,"Any","Blue"],
		[29,"Any","Blue"],
		[55,"Any","Blue"],
		[60,"Any","Red"],
		[70,"Any","Blue"],
		[70,"Any","Blue"],
	]
	
func _level6():
	level_flavor_text.text = "\
	Day 6
	You got a third Washing Machine
	A lot of people are coming to try out your laundrymat
	" 
	
	star_1_score = 12000
	star_2_score = 16000
	star_3_score = 23000	

	$"../ElectricityShower".ready2(11)
	$"../WashingMachines/WashingMachine4".queue_free()
	Customer.wait_outside_min = 30
	Customer.wait_outside_max = 60
	level_spawn = [
		[0,"Any","Blue"],
		[0,"Any","Red"],
		[0,"Any","White"],
		[6,"Any","Red"],
		[12,"Any","Red"],
		[18,"Any","Blue"],
		[19,"Any","Blue"],
		[19,"Any","Blue"],
		[19,"Any","Blue"],
		[25,"Any","Red"],
		[25,"Any","Red"],
		[25,"Any","Red"],
		[35,"Any","Red"],
		[35,"Any","Red"],
		[35,"Any","Red"],
		[55,"Any","Red"],
		[55,"Any","Red"],
		[55,"Any","Red"],
		[55,"Any","Red"],
		[55,"Any","White"],
		[55,"Any","Blue"],
		[75,"Any","Blue"],
		[95,"Any","White"],
		[100,"Any","Red"]	
	]
	
func _level7():
	level_flavor_text.text = "\
	Day 7
	Demon party is in town!
	They come in waves
	They come back much later
	" 
	
	star_1_score = 14000
	star_2_score = 24000
	star_3_score = 26000	
	
	$"../ElectricityShower".ready2(11)
	$"../WashingMachines/WashingMachine4".queue_free()
	Customer.wait_outside_min = 70
	Customer.wait_outside_max = 70
	level_spawn = [
		[0,"Shirt","Black"],
		[0,"Shirt","Black"],
		[0,"Shirt","Black"],
		[0,"Shirt","Black"],
		[0,"Shirt","Black"],
		[0,"Shirt","Black"],
		[0,"Shirt","Black"],
		[0,"Shirt","Black"],
		[30,"Jeans","Black"],
		[30,"Jeans","Black"],
		[30,"Jeans","Black"],
		[30,"Jeans","Black"],
		[30,"Jeans","Black"],
		[30,"Jeans","Black"],
		[30,"Jeans","Black"],
		[40,"Jeans","Blue"],
		[60,"Socks","Black"],
		[60,"Socks","Black"],
		[60,"Socks","Black"],
		[62,"Socks","Black"],
		[62,"Socks","Black"],
		[62,"Socks","Black"],
		[62,"Socks","Black"],
		[64,"Socks","Black"],
		[64,"Socks","Black"],
		[64,"Socks","Black"],
		[64,"Socks","Black"],
		[64,"Socks","Black"],	
	]
	
func _level8():
	level_flavor_text.text = "\
	Day 8
	Your electricity is acting up again!
	People are funneling in every second!
	" 
	
	star_1_score = 30000
	star_2_score = 45000
	star_3_score = 58000	
	
	$"../ElectricityShower".ready2(9)
	$"../WashingMachines/WashingMachine4".queue_free()
	Customer.wait_outside_min = 60
	Customer.wait_outside_max = 60
	
	level_spawn = []
	for i in range(60):
		level_spawn.push_back([i,"Any","Blue"])
	
func _level9():
	level_flavor_text.text = "\
	Day 9
	You got yourself a 4th machine!
	Electricity is OK too
	People want their stuff immediatelly Today
	" 
	star_1_score = 15000
	star_2_score = 25000
	star_3_score = 37000	
	
	$"../ElectricityShower".ready2(14)
	Customer.wait_outside_min = 1
	Customer.wait_outside_max = 1
	level_spawn = [
		[0,"Any","Blue"],
		[0,"Any","Red"],
		[0,"Any","White"],
		[0,"Any","Blue"],
		[0,"Any","Red"],
		[0,"Any","White"],
		[6,"Any","Black"],
		[12,"Any","Any"],
		[12,"Any","Any"],
		[12,"Any","Any"],
		[12,"Any","Any"],
		[12,"Any","Any"],
		[18,"Any","Any"],
		[19,"Any","Any"],
		[19,"Any","Any"],
		[19,"Any","Any"],
		[25,"Any","Any"],
		[25,"Any","Any"],
		[25,"Any","Any"],
		[25,"Any","Any"],
		[25,"Any","Any"],
		[25,"Any","Any"],
		[25,"Any","Any"],
		[35,"Any","Any"],
		[35,"Any","Any"],
		[35,"Any","Any"],
		[35,"Any","Any"],
		[35,"Any","Any"],
		[35,"Any","Any"],
		[35,"Any","Any"],
		[55,"Any","Any"],
		[55,"Any","Any"],
		[55,"Any","Any"],
		[55,"Any","Any"],
		[55,"Any","Any"],
		[55,"Any","Any"],
		[75,"Any","Any"],
		[95,"Any","Any"],
		[100,"Any","Any"],
	]
	
func _level10():
	level_flavor_text.text = "\
	Day 10
	Wash your forgotten jeans Holiday Today
	People will bring their clothes, and leave for a while
	" 
	star_1_score = 40000
	star_2_score = 70000
	star_3_score = 82000
	
	$"../ElectricityShower".ready2(14)
	Customer.wait_outside_min = 80
	Customer.wait_outside_max = 80
	level_spawn = []
	for i in range(10):
		level_spawn.push_back([i / 2,"Jeans","Blue"])
	for i in range(15):
		level_spawn.push_back([i / 2 + 30,"Jeans","Blue"])
	for i in range(15):
		level_spawn.push_back([i / 2 + 70,"Jeans","White"])
	for i in range(15):
		level_spawn.push_back([i / 2 + 95,"Jeans","Black"])
	for i in range(30):
		level_spawn.push_back([i + 120,"Jeans","Black"])
	
	
func _process(delta):
	if game_over:
		return
	
	# Balancing for my inability to create balanced scenarios
	if customers_around > 10:
		elapsed_time += delta * 0.5
	elif customers_around > 5:
		elapsed_time += delta * 0.75
	else:
		elapsed_time += delta
	
	if level_spawn.size() > 0:
		var next_spawn = level_spawn[0]
		if next_spawn[0] < elapsed_time:
			customer_spawner.spawn_customer(next_spawn[2], next_spawn[1])
			level_spawn.pop_front()
	elif customers_around == 0:
		_game_over()

func _game_over():
	if game_over:
		return
	game_over = true
	var isNewHighScore = false
	if score > SignalBus.level_max_scores[level_id-1]:
		SignalBus.level_max_scores[level_id-1] = score
		isNewHighScore = true
	
	var gameOverControl = $"../CanvasLayer/GameOverControl" as GameOverControl
	var starCount = 0
	if score >= star_1_score: 
		starCount+=1
	if score >= star_2_score: 
		starCount+=1
	if score >= star_3_score: 
		starCount+=1
		
	if starCount > SignalBus.level_max_stars[level_id-1]:
		SignalBus.level_max_stars[level_id-1] = starCount
		isNewHighScore = true
	
	SignalBus.save()
	game_over_player.play()	
	gameOverControl.game_over(score, isNewHighScore, starCount, level_id + 1)
	
# at this point im just purosefully doing dirty code
var hack1 = 3	
func turn_off_on_clean_cloth_collision():
	hack1 *= -1
	($"../CleanClothesArea" as Area2D).global_position -= Vector2(0,2000 * hack1)
	$"../Timer".start(hack1 + 4)
