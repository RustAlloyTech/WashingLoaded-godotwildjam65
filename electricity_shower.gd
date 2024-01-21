extends Node2D

@export var max_electricity : int = 0
@export var washing_machines : Array[WashingMachine]
@export var electric_switch : ElectricSwitch
@export var electric_lights : Node2D

const ELECTRICITY_LED_LIGHT = preload("res://electricity_led_light.tscn")

var current_electricity
var leds : Array[ElectricityLedLight]

func _ready():
	SignalBus.signal_energy_usage_changed.connect(_on_energy_changed)
	SignalBus.signal_electric_switch_turned_on.connect(turn_electricity_on)
	SignalBus.signal_electric_switch_turned_off.connect(turn_electricity_off)
	
	
func ready2(max_e:int):
	max_electricity = max_e
	for i in range(max_electricity):
		var eled = ELECTRICITY_LED_LIGHT.instantiate()
		add_child(eled)
		eled.scale = Vector2(5,2)
		eled.position = Vector2(0,i * -15)
		eled.turn_off()
		leds.push_back(eled)

func _on_energy_changed():
	current_electricity = 0
	for washing_machine in washing_machines:
		if washing_machine != null:
			current_electricity += washing_machine.electric_demand
	if current_electricity > max_electricity:
		_crash()
	_redraw_electricity()
	
func _crash():
	electric_switch.turn_off()
	
	
func turn_electricity_on():
	for washing_machine in washing_machines:
		if washing_machine != null:
			washing_machine.electricity_turned_on()
	for light : LightCeiling in electric_lights.get_children():
		if light != null:
			light.electricity_turned_on()
	SignalBus.signal_power_up.emit()

	
func turn_electricity_off():
	for washing_machine in washing_machines:
		if washing_machine != null:
			washing_machine.electricity_turned_off()
	for light : LightCeiling in electric_lights.get_children():
		if light != null:
			light.electricity_turned_off()
	SignalBus.signal_power_down.emit()
	
func _redraw_electricity():
	var turn_red_please = false
	if current_electricity >= max_electricity:
		turn_red_please = true
	for i in range(max_electricity):
		if turn_red_please:
			leds[i].turn_red()
		elif current_electricity > i:
			leds[i].turn_on()
		else:
			leds[i].turn_off()
