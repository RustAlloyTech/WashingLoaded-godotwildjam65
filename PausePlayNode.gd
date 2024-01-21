extends Node2D

var paused = true

func _input(event: InputEvent):
	if (event.is_action_pressed("Space")) and paused:
		_on_button_pressed()


func _on_button_pressed():
	paused = false
	get_tree().paused = false
	$"..".visible = false
	$"../../AudioStreamPlayer".play()

