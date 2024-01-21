extends CharacterBody2D
class_name Customer

@export var laundry_color : String # White / Blue / Red
@export var laundry_type : String  # Jeans / Shirt / Socks
@export var item_placement_area: Area2D
@export var item_placement_desk_mark: Marker2D
@export var visible_color: Color

@export var waiting_area: Area2D
@export var nav_region : NavigationRegion2D
@export var cloth_i_came_with : Cloth

@export var state : String = "Spawning" # Arriving / Waiting / Leaving

@onready var timer = $Timer
@onready var nav = $NavigationAgent2D
@onready var animation_tree = $AnimationTree
@onready var animation_player_2 = $AnimationPlayer2
@onready var item_holding = $Body/Hands/Hand2Container/SpritesheetPlayerHand2/Holder/HolderArea/ItemHolding

@onready var greetings_player = $GreetingsPlayer
@onready var unhappy_player = $UnhappyPlayer
@onready var happy_player = $HappyPlayer



static var wait_outside_min = 10
static var wait_outside_max = 20


var speed = 300
var accel = 7

var target_position : Vector2
var target_clean_cloth : Cloth

const score_penalty_dirty_cloth = 700
const score_penalty_too_long_waiting = 200
const score_penalty_mashed_colors = 400
const score_bonus_coffee_served = 200


var score = 1000

var did_i_have_dirty_cloth = false
var did_i_have_mashed_up_cloth = false
var did_have_coffee = false
var waited_too_much = 0

func _ready():
	call_deferred("ready2")
	
func ready2():
	await get_tree().physics_frame
	target_position = Vector2(item_placement_area.global_position)
	target_position += Vector2(0, randf_range(-200,120))
	nav.target_position = target_position
	_pick_up(cloth_i_came_with)
	state = "Arriving"
	animation_tree.active = true
	_recolor()
	if laundry_type == "Jeans":
		$Body/BodyContainer/Body/SpritesheetBodyJeansOff.visible = true
	elif laundry_type == "Shirt":
		$Body/BodyContainer/Body/SpritesheetBodyShirtOff.visible = true
	elif laundry_type == "Socks":
		$Body/Leg1Container/Leg1.self_modulate = Color(0,0,0,0)
		$Body/Leg2Container/Leg2.self_modulate = Color(0,0,0,0)
		$Body/Leg1Container/Leg1/SpritesheetLeg1SocksOff.visible = true
		$Body/Leg2Container/Leg2/SpritesheetLeg2SocksOff.visible = true
		
	SignalBus.signal_clean_cloth_ready_for_pickup.connect(do_i_need_that_cloth)
	SignalBus.signal_clean_cloth_yoinked.connect(was_my_cloth_got_yoinked)
	SignalBus.signal_customer_arrived.emit()

func do_i_need_that_cloth(cloth : Cloth):
	if cloth.laundry_logic_color == laundry_color and cloth.laundry_type == laundry_type:
		if cloth.has_yoinker == false and target_clean_cloth == null:
			cloth.has_yoinker = true
			target_clean_cloth = cloth
			if state == "Waiting3" or state == "Waiting2" or state == "Waiting1":
				_go_hunt_cloth()

func was_my_cloth_got_yoinked(cloth: Cloth):
	if item_holding.get_child_count() > 0:
		return
	if cloth == target_clean_cloth:
		_my_target_cloth_got_yoinked()

func _my_target_cloth_got_yoinked():
	target_clean_cloth = null
	_start_timer("Waiting")
	state = "Waiting"

func _recolor():
	var head_color_mul = 0.8
	($Body/BodyContainer/Body as Node2D).self_modulate = visible_color
	($Body/HeadContainer/Head as Node2D).self_modulate = Color(
		 1 - head_color_mul + visible_color.r * head_color_mul,
		 1 - head_color_mul + visible_color.g * head_color_mul,
		 1 - head_color_mul + visible_color.b * head_color_mul,
		 1
	)
	($Body/Leg1Container/Leg1 as Node2D).self_modulate = visible_color
	($Body/Leg2Container/Leg2 as Node2D).self_modulate = visible_color
	($Body/Hands/Hand1Container/SpritesheetPlayerHand1 as Node2D).self_modulate = visible_color
	($Body/Hands/Hand2Container/SpritesheetPlayerHand2 as Node2D).self_modulate = visible_color
	
	
func _pick_up(cloth : Cloth):
	if cloth.get_parent() != null:
		if cloth.get_parent().name == "LaundryStorageInside":
			var washing_machine = cloth.get_parent().get_parent().get_parent().get_parent() as WashingMachine
			washing_machine.add_weight(-cloth.weight)
		cloth.get_parent().remove_child(cloth)
	item_holding.add_child(cloth)
	cloth.position = Vector2(0,0)
	cloth.freeze = true
	
func _put_down_to_desk():
	var x = item_placement_desk_mark.global_position.x + randf_range(-2,10)
	var y = global_position.y
	cloth_i_came_with.get_parent().remove_child(cloth_i_came_with)
	get_parent().get_parent().add_child(cloth_i_came_with)
	cloth_i_came_with.global_position = Vector2(x,y)
	cloth_i_came_with.freeze = false
	
func _navigate_there(delta):
	var next = nav.get_next_path_position()
	var glob = global_position
	var dir = (next - glob)
	var direction = dir.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)

func _physics_process(delta):
	_animate()
	if state == "Arriving":
		if !nav.is_navigation_finished():
			_navigate_there(delta)
		else:
			_start_timer("PuttingDown", 2)
	elif state == "Waiting2":
		if !nav.is_navigation_finished():
			_navigate_there(delta)
		else:
			if target_clean_cloth != null:
				_go_hunt_cloth()
			else:
				_start_timer("Waiting3", wait_outside_max, wait_outside_min)
	elif state == "Waiting4":
		if !nav.is_navigation_finished():
			_navigate_there(delta)
		else:
			_start_timer("Waiting")
	elif state == "HuntCloth":
		if !nav.is_navigation_finished():
			target_position = target_clean_cloth.global_position
			nav.target_position = target_position
			_navigate_there(delta)
		else:
			if target_clean_cloth.get_parent().name != "ItemHolding":
				_pick_up(target_clean_cloth)
				state = "JustPickedUp"
				_start_timer("GoHome")
				target_position = Vector2(-300,200)
				nav.target_position = target_position
				if target_clean_cloth.am_i_dirty():
					animation_tree.active = false
					animation_player_2.play("Angry_1")
					$Body/HeadContainer/Head/SpritesheetThinkBalloon.visible = true
					$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetDirt.visible = true
					score -= score_penalty_dirty_cloth
				if target_clean_cloth.am_i_mashed():
					animation_tree.active = false
					animation_player_2.play("Angry_1")
					$Body/HeadContainer/Head/SpritesheetThinkBalloon.visible = true
					$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetNotEqual.visible = true
					var prev_cloth_think : Sprite2D
					var now_cloth_think : Sprite2D
					if laundry_type == "Jeans":
						prev_cloth_think = $Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetJeans
						now_cloth_think = $Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetJeans/SpritesheetJeans2
					elif laundry_type == "Socks":
						prev_cloth_think = $Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetSocks
						now_cloth_think = $Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetSocks/SpritesheetSocks2
					else:
						prev_cloth_think = $Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetTshirt
						now_cloth_think = $Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetTshirt/SpritesheetTshirt2
						
					prev_cloth_think.visible = true
					prev_cloth_think.self_modulate = visible_color
					now_cloth_think.self_modulate = target_clean_cloth.modulate
					
					score -= score_penalty_mashed_colors
				score -= waited_too_much * 150
				if score < 100:
					score = 100
				
				if score > 700:
					var randEyes = randi_range(1,6)
					var randMouth = randi_range(1,4)
					if randEyes == 1:
						$Body/HeadContainer/Head/SpritesheetHappyEyes1.visible = true
					if randEyes == 2:
						$Body/HeadContainer/Head/SpritesheetHappyEyes2.visible = true
					if randEyes == 3:
						$Body/HeadContainer/Head/SpritesheetHappyEyes3.visible = true
					if randEyes == 4:
						$Body/HeadContainer/Head/SpritesheetHappyEyes4.visible = true
					if randEyes == 5:
						$Body/HeadContainer/Head/SpritesheetHappyEyes5.visible = true
					if randEyes == 6:
						$Body/HeadContainer/Head/SpritesheetHappyEyes6.visible = true
						
					if randMouth == 1:
						$Body/HeadContainer/Head/SpritesheetHappyMouth1.visible = true
					if randMouth == 2:
						$Body/HeadContainer/Head/SpritesheetHappyMouth2.visible = true
					if randMouth == 3:
						$Body/HeadContainer/Head/SpritesheetHappyMouth3.visible = true
					if randMouth == 4:
						$Body/HeadContainer/Head/SpritesheetHappyMouth4.visible = true
					happy_player.play()
				else:
					unhappy_player.play()
				SignalBus.signal_point_increased.emit(score)
				SignalBus.signal_customer_left.emit()
			else:
				_my_target_cloth_got_yoinked()
	elif state == "GoHome":
		
		animation_tree.active = true
		if !nav.is_navigation_finished():
			_navigate_there(delta)
		else:
			_start_timer("AtHome")
	else:
		velocity = velocity.lerp(Vector2(0,0), accel * delta)
	move_and_slide()
		
func _animate():
	var velo = max(abs(velocity.x), abs(velocity.y)) / speed
	animation_tree.set("parameters/blend_position", -1 + 2 * velo)

func _start_timer(next_state: String, max_wait: float = 4.0, min_wate: float = 0.5):
	state = next_state
	timer.wait_time = randf_range(0.5, max_wait)
	timer.start()

func _reset_animation_stuff():
	$Body/HeadContainer/Head/SpritesheetThinkBalloon.visible = false
	$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetSandTimer.visible = false
	$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetNotEqual.visible = false
	$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetJeans.visible = false
	$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetSocks.visible = false
	$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetTshirt.visible = false
	$Body/HeadContainer/Head/SpritesheetAngryFace.visible = false

var waitCounter = 0

func _go_hunt_cloth():
	target_position = target_clean_cloth.global_position
	nav.target_position = target_position
	animation_tree.active = true
	state = "HuntCloth"
	timer.stop()
	return

func _on_timer_timeout():
	_reset_animation_stuff()
	if state == "PuttingDown":
		_put_down_to_desk()
		greetings_player.play()
		_start_timer("Waiting1")
	elif state == "Waiting1":
		# no idea how to get the a rectangle shape's coordinates back
		target_position = Vector2(-200,randf_range(550,650)) 
		nav.target_position = target_position
		if target_clean_cloth != null:
			_go_hunt_cloth()
		else:
			state = "Waiting2"
	elif state == "Waiting3":
		target_position = Vector2(randf_range(200,800),randf_range(550,650)) 
		nav.target_position = target_position
		state = "Waiting4"
	elif state == "Waiting":
		if target_clean_cloth != null:
			if target_clean_cloth.get_parent().name != "ItemHolding":
				_go_hunt_cloth()
			else:
				_my_target_cloth_got_yoinked()
		else:
			animation_tree.active = false
			if waited_too_much == 3:
				score = 0
				_start_timer("GoHome",1,2)
				target_position = Vector2(-300,200)
				nav.target_position = target_position
				animation_player_2.play("Angry_1")
				SignalBus.signal_customer_left.emit()
				return
			waitCounter += 1
			if waitCounter % 15 == 0 && waitCounter > 30:
				unhappy_player.play()
				animation_player_2.play("Angry_1")
				waited_too_much += 1
				$Body/HeadContainer/Head/SpritesheetThinkBalloon.visible = true
				$Body/HeadContainer/Head/SpritesheetThinkBalloon/SpritesheetSandTimer.visible = true
			else:
				animation_player_2.play("Dancing_1")
			_start_timer("Waiting",2,2)
	elif state == "AtHome":
		_start_timer("WatchTv")
	elif state == "WatchTv":
		queue_free()
