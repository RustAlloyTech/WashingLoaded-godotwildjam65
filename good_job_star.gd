extends Node2D
class_name GoodJobStar

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func menu_starred(starred: bool):
	$EmptyStar.visible = !starred
	$Star.visible = starred
	$StarEffect.visible = false
	if starred:
		animation_player.play("Star")

func good_job():
	animation_player.play("Star")
	
func bad_job():
	animation_player.play("EmptyStar")
