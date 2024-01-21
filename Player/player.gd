extends CharacterBody2D


const SPEED = 300.0
const inertia = 0.9

@onready var animation_tree = $AnimationTree
@onready var item_holding = $Holder/HolderArea/ItemHolding
@onready var holder = $Holder
@onready var holder_area = $Holder/HolderArea
@onready var point_light_2d = $Holder/HolderArea/PointLight2D

@onready var beep_boop_player = $BeepBoopPlayer
@onready var unhappy_player = $UnhappyPlayer


@export var bandaig_holder: BandaidHolder
@export var power_switch: ElectricSwitch


func _ready():
	animation_tree.active = true

func _pick_up(cloth : Cloth):
	point_light_2d.visible = false
	if cloth.get_parent().name == "LaundryStorageInside":
		var washing_machine = cloth.get_parent().get_parent().get_parent().get_parent() as WashingMachine
		washing_machine.add_weight(-cloth.weight)
	cloth.is_held = true
	cloth.inside_washing_machine = false
	SignalBus.signal_clean_cloth_yoinked.emit(cloth)
	cloth.get_parent().remove_child(cloth)
	item_holding.add_child(cloth)
	cloth.has_yoinker = false
	cloth.position = Vector2(0,0)
	cloth.has_yoinker = false
	cloth.freeze = true

func _put_down():
	point_light_2d.visible = true
	var angular_instability = 0.1
	for cloth : Cloth in item_holding.get_children():
	#var cloth = (item_holding.get_children()[0]) as RigidBody2D
		var pos = cloth.global_position
		item_holding.remove_child(cloth)
		get_parent().add_child(cloth)
		cloth.global_position = pos
		cloth.freeze = false
		cloth.linear_velocity = velocity * (4 + angular_instability)
		cloth.linear_velocity = cloth.linear_velocity.rotated(randf_range(-angular_instability,angular_instability))
		angular_instability += 0.1
		cloth.is_held = false

func _get_waching_machine() -> WashingMachine:
	var areas = holder_area.get_overlapping_areas()
	var washing_machines = areas.filter(func(node: Node2D): 
		var par = node.get_parent()
		var iswash = par.has_method("put_in_laundry")
		return iswash
		)
	if washing_machines.size() > 0:
		return washing_machines[0].get_parent()
	return null

func _filter_clothes_on_the_floor(body):
	var cloth = body as Cloth
	if cloth == null:
		return false
	if cloth.inside_washing_machine or cloth.is_held:
		return false
	return true
	
func _filter_clothes_in_washing_machine(body):
	var cloth = body as Cloth
	if cloth == null:
		return false
	if cloth.inside_washing_machine:
		return true
	return false

func _physics_process(delta):
	_movement()

	_animate()
	
	var washing_machine : WashingMachine
	
	if Input.is_action_just_pressed("E") or Input.is_action_just_pressed("Space"):
		washing_machine = _get_waching_machine()
	
	if Input.is_action_just_pressed("E"): 
		if washing_machine != null:
			washing_machine.open_close_door()
		else:
			var bodies = holder_area.get_overlapping_bodies()
			var switches = bodies.filter(func(electricswitch): return (electricswitch.get_parent() as ElectricSwitch) != null)
			if switches.size() > 0:
				var switch = switches[0].get_parent() as ElectricSwitch
				switch.interact()
				beep_boop_player.play()
	
	if Input.is_action_just_pressed("Space"):
		var bodies = holder_area.get_overlapping_bodies()
		var clothes_on_floor = bodies.filter(_filter_clothes_on_the_floor) as Array[Cloth]
		var clothes_in_washing_machine = bodies.filter(_filter_clothes_in_washing_machine) as Array[Cloth]
			
		var items_held = item_holding.get_children()
		var band_aid : Cloth = null
		for cloth : Cloth in items_held:
			if cloth.laundry_type == "Bandaid":
				band_aid = cloth
				break
		
		if washing_machine != null and band_aid != null and washing_machine.damage > 0:
			washing_machine.repair()
			if items_held.size() == 1:
				point_light_2d.visible = true
			band_aid.queue_free()
		
		elif items_held.size() > 0 and washing_machine != null and washing_machine.open:
			var all_cloth_fit = true
			for cloth in items_held:
				all_cloth_fit = washing_machine.put_in_laundry(cloth)
				if all_cloth_fit:
					cloth.is_held = false
			if all_cloth_fit:
				point_light_2d.visible = true
					
		elif washing_machine != null and !washing_machine.open :
			var dobeepboop = true
			if washing_machine.is_washing_machine_power_off():
				power_switch.blink_it()
				unhappy_player.play()
				dobeepboop = false
			if washing_machine.is_washing_machine_destroyed():
				if bandaig_holder != null:
					bandaig_holder._blink_it()
					unhappy_player.play()
					dobeepboop = false
			washing_machine.start_stop()
			if dobeepboop:
				beep_boop_player.play()
			
		elif items_held.size() > 0 and clothes_on_floor.size() == 0:
			_put_down()
		
		elif clothes_on_floor.size() > 0:
			_pick_up(clothes_on_floor[0])
			
		elif items_held.size() == 0 and washing_machine != null:
			if clothes_in_washing_machine.size() > 0:
				for cloth_in_washing_machine in clothes_in_washing_machine:
					_pick_up(cloth_in_washing_machine)
		
		#if item_holding.get_child_count() == 0:
			##var bodies = holder_area.get_overlapping_bodies()
			##var clothes = bodies.filter(func(clothnode): return clothnode.has_method("i_am_a_cloth"))
			#if clothes_on_floor.size() > 0:
				#_pick_up(clothes_on_floor[0])
			#else:
				#if washing_machine != null:
					#washing_machine.start_stop()
		#else:
			#if washing_machine != null:
				#point_light_2d.visible = true
				#washing_machine.put_in_laundry(item_holding.get_children()[0])
			#else:
				#_put_down()

func _animate():
	var velo = max(abs(velocity.x), abs(velocity.y)) / SPEED
	animation_tree.set("parameters/blend_position", -1 + 2 * velo)

func _movement():
	var direction_x = Input.get_axis("Left", "Right")
	var direction_y = Input.get_axis("Up", "Down")
	var targetspeed_x = 0
	var targetspeed_y = 0
	
	var direction = Vector2(direction_x, direction_y)
	
	if direction_x:
		targetspeed_x = direction_x * SPEED
	else:
		targetspeed_x = move_toward(velocity.x, 0, SPEED)
	
	velocity.x = velocity.x * inertia + targetspeed_x * (1-inertia)
	
	if direction_y:
		targetspeed_y = direction_y * SPEED
	else:
		targetspeed_y = move_toward(velocity.y, 0, SPEED)
		
	velocity.y = velocity.y * inertia + targetspeed_y * (1-inertia)
	
	#rad_to_deg()
	
	if direction.length() > 0.3:
		# stupid code, works
		var dgr = direction.angle()
		var first = holder.rotation - dgr
		var second = holder.rotation - PI * 2 - dgr
		var third = holder.rotation + PI * 2 - dgr
		
		if abs(first) > abs(second):
			holder.rotation -= PI * 2
		elif abs(first) > abs(third):
			holder.rotation += PI * 2
			
		holder.rotation = holder.rotation * 0.9 + dgr * 0.1
	
	move_and_slide()
