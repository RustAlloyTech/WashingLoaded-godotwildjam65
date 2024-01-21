extends Button

@export var level_number : int

var highscore : int
var star_count : int
# Called when the node enters the scene tree for the first time.
func _ready():
	highscore = SignalBus.level_max_scores[level_number-1]
	star_count = SignalBus.level_max_stars[level_number-1]
	text = "Level " + str(level_number)
	$GoodJobStar.menu_starred(star_count > 0)
	$GoodJobStar2.menu_starred(star_count > 1)
	$GoodJobStar3.menu_starred(star_count > 2)
	$Label.text = "HighScore: " + str(highscore)

func play_level():
	SignalBus.current_level = level_number
	get_tree().change_scene_to_file("res://game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed((level_number % 10) + 48):
		play_level()

