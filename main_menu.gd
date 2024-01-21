extends Control

func _on_start_button_pressed():
	play_level(1)
	
func _on_level_select_button_pressed():
	$MainMenu.visible = false
	$LevelSelect.visible = true

func _on_level_select_back_button_pressed():
	$MainMenu.visible = true
	$LevelSelect.visible = false

func play_level(i: int):
	SignalBus.current_level = i
	get_tree().change_scene_to_file("res://game.tscn")

func _on_exit_button_pressed():
	$MainMenu/ExitButton.text = "Press CTRL + W to close the tab :)"

func _process(delta):
	if Input.is_action_just_pressed("Space"):
		_on_start_button_pressed()
	if Input.is_action_just_pressed("Esc"):
		_on_exit_button_pressed()
	if Input.is_action_just_pressed("E"):
		if $MainMenu.visible:
			_on_level_select_button_pressed()
		else:
			_on_level_select_back_button_pressed

var sfx_enabled = true

func _on_disable_sfx_pressed():
	var bus = AudioServer.get_bus_index("SFX")
	sfx_enabled = !sfx_enabled
	AudioServer.set_bus_mute(bus, !sfx_enabled)
	if sfx_enabled:
		$MainMenu/DisableSFX.text = "Disable SFX Again"
	else:
		($MainMenu/DisableSFX as Button).text = "Enable SFX"

var music_enabled = true


func _on_disable_music_button_pressed():
	var bus = AudioServer.get_bus_index("BGMusic")
	music_enabled = !music_enabled
	AudioServer.set_bus_mute(bus, !music_enabled)
	if music_enabled:
		$MainMenu/DisableMusicButton.text = "Disable Music Again"
	else:
		$MainMenu/DisableMusicButton.text = "Enable Music"






func _on_start_day_6_pressed():
	SignalBus.current_level = 6
	get_tree().change_scene_to_file("res://game.tscn")
