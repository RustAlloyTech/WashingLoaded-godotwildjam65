extends Node2D
class_name WashingMachine

@export var total_weight = 0
@export var open = false
@export var started = false
@export var electric_demand = 0

var power_off = false
var damage = 0

@onready var loaded_led = $Body/LoadedLed
@onready var animation_player = $AnimationPlayer
@onready var laundry_storage = $Body/LaundryStorage/LaundryStorageInside
@onready var electric_demand_led = $Body/ElectricDemandLed
@onready var working_light = $WorkingLight
@onready var stopped_light = $StoppedLight
@onready var audio_stream_player_2d = $AudioStreamPlayer2D


func _set_electric_demand(e: int):
	electric_demand = e
	_update_electric_demand_led()
	SignalBus.signal_energy_usage_changed.emit()
	

func add_weight(w : int):
	total_weight += w
	_update_weight_led()
	
func open_close_door():
	if started:
		return
	open = !open
	if open:
		animation_player.play("open_close_door")
		laundry_storage.get_children().all(func(cx: RigidBody2D): 
			cx.set_collision_layer_value(2, true)
			return true
			)
	else:
		animation_player.play_backwards("open_close_door")
		laundry_storage.get_children().all(func(cx: RigidBody2D): 
			cx.set_collision_layer_value(2, false)
			return true
			)

func put_in_laundry(cloth: Cloth) -> bool:
	if open and total_weight < 20:
		cloth.inside_washing_machine = true
		cloth.get_parent().remove_child(cloth)
		laundry_storage.add_child(cloth)
		cloth.position = Vector2(randf_range(-10,10),randf_range(-10,10))
		add_weight(cloth.weight)
		return true
	return false

func electricity_turned_off():
	power_off = true
	if started:
		animation_player.play("washing_stop")
		started = false
		_update_electric_demand_led()
		audio_stream_player_2d.stop()
	_update_weight_led()

func electricity_turned_on():
	power_off = false
	#if started:
		#animation_player.play()
		#_update_electric_demand_led()
	_update_weight_led()

func is_washing_machine_destroyed() -> bool:
	if damage >=2:
		return true
	return false


func is_washing_machine_power_off() -> bool:
	return power_off 

func start_stop() -> bool:
	if open:
		return false
	if damage >= 2:
		return false
	started = !started
	if power_off:
		started = false
	if started:
		audio_stream_player_2d.play()
		animation_player.play("washing")
	else:
		audio_stream_player_2d.stop()
		animation_player.play("washing_stop")
	return true

func _update_weight_led():
	var leds = loaded_led.get_children()
	for i in range(10):
		if power_off:
			leds[i].visible = false
		else:
			leds[i].visible = total_weight >= i * 2

func _update_electric_demand_led():
	var leds = electric_demand_led.get_children()
	for i in range(5):
		leds[i].visible = electric_demand > i

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_weight_led()
	_update_electric_demand_led()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _clothes_color_masher():
	var clothes = laundry_storage.get_children() as Array[Cloth]
	var clothcount = clothes.size()
	var color = Color(0,0,0,0)
	for cloth in clothes:
		var c = cloth.modulate
		color += c
	color /= clothcount
	for cloth in clothes:
		cloth.modulate = color / 4 + cloth.modulate * 3 / 4

func _draw_damage_look():
	$Body/Body.visible = false
	$Body/BodyDamaged.visible = false
	$Body/BodyDestroyed.visible = false
	if damage == 0:
		$Body/Body.visible = true
	if damage == 1:
		$Body/BodyDamaged.visible = true
	if damage == 2:
		$Body/BodyDestroyed.visible = true


func _make_clothes_clean():
	var clothes = laundry_storage.get_children() as Array[Cloth]
	if clothes.size() > 0:
		var logic_color = clothes[0].laundry_logic_color
		var mashed_colors = false
		for cloth : Cloth in clothes:
			cloth.washing_cycle_complete()
			if logic_color != cloth.laundry_logic_color:
				mashed_colors = true
		if mashed_colors:
			for cloth : Cloth in clothes:
				cloth.mashed_color = true
	if total_weight >= 10:
		damage += 1
		$DamagePlayer.play()
	if total_weight >= 16:
		damage += 1
	if damage > 2:
		damage = 2
	_draw_damage_look()
					
func repair():
	damage = 0
	_draw_damage_look()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "washing":
		started = false
		audio_stream_player_2d.stop()
		open_close_door()
		
