extends Control
class_name GameOverControl

@onready var game_over_score_label = $Panel/GameOverScoreLabel
@onready var new_highscore_label = $Panel/NewHighscoreLabel

@onready var good_job_star  : GoodJobStar = $Panel/GoodJobStar
@onready var good_job_star_2 : GoodJobStar = $Panel/GoodJobStar2
@onready var good_job_star_3 : GoodJobStar = $Panel/GoodJobStar3

@onready var timer = $Timer

var stars : Array[GoodJobStar]
var star_index : int = 0
var star_count : int

# Called when the node enters the scene tree for the first time.
func _ready():
	stars = [good_job_star, good_job_star_2, good_job_star_3]
	#game_over(2000, true, 2, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func game_over(score: int, isNewHighScore: bool, starCount: int, nextLevel: int):
	visible = true
	star_count = starCount
	game_over_score_label.text = str(score)
	if isNewHighScore:
		new_highscore_label.visible = true
	timer.start()
	if nextLevel == 11:
		$NextLevelButton.visible = false

func _on_timer_timeout():
	if star_count > star_index:
		stars[star_index].good_job()
	else:
		stars[star_index].bad_job()
	star_index += 1
	if star_index == 3:
		timer.stop()


func _on_back_to_main_menu_button_pressed():
	SignalBus.signal_back_to_main_menu_button_pressed.emit()


func _on_try_again_button_pressed():
	SignalBus.signal_try_again_button_pressed.emit()


func _on_next_level_button_pressed():
	SignalBus.signal_next_level_button_pressed.emit()
