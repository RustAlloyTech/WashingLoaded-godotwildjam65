extends Sprite2D
class_name ElectricSwitch

@onready var animation_player = $AnimationPlayer
@onready var blink_player = $BlinkPlayer

var turned_on = true

func interact():
	if turned_on:
		turn_off()
	else:
		turn_on()

func blink_it():
	blink_player.play("blink")

func turn_on():
	animation_player.play("SwitchOn")

func turn_off():
	turned_on = false
	animation_player.play("SwitchOff")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "SwitchOn":
		turned_on = true
		SignalBus.signal_electric_switch_turned_on.emit()
	elif anim_name == "SwitchOff":
		#turned_on = true
		SignalBus.signal_electric_switch_turned_off.emit()
