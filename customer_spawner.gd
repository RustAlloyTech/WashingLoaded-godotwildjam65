extends Node2D
class_name CustomerSpawner

@export var item_placement_area: Area2D
@export var item_placement_desk_mark: Marker2D
@export var customers_storage : Node2D
@export var max_color : int = 4

@export var waiting_area: Area2D
@export var nav_region : NavigationRegion2D

const CUSTOMER = preload("res://Customer/customer.tscn")

const colors = ["White", "Blue", "Red", "Black"] 
const cloth_types = ["Shirt", "Socks", "Jeans"]
const cloth_preloads : Array[PackedScene] = [preload("res://Clothes/Shirt.tscn"), preload("res://Clothes/Socks.tscn"), preload("res://Clothes/jeans.tscn")] 


func spawn_cloth(color_index, cloth_type_index):
	var color = colors[color_index]
	var cloth_type = cloth_types[cloth_type_index]
	var cloth_type_preload = cloth_preloads[cloth_type_index]
	var visible_color : Color
	if color == "White":
		var rand = randf_range(0.7, 1)
		visible_color = Color(rand,rand,rand,1)
	if color == "Blue":
		var randgreen = randf_range(0,0.7)
		var randred = randf_range(0, randgreen)
		visible_color = Color(randred,randgreen,1,1)
	if color == "Red":
		var randblue = randf_range(0.0, 0.4)
		var randgreen = randf_range(0.0, randblue)
		var randred = randf_range(0.8,1.0)
		visible_color = Color(randred,randgreen,randblue,1)
	if color == "Black":
		var rand = randf_range(0.0, 0.12)
		visible_color = Color(rand,rand,rand,1)
		
	var cloth = cloth_type_preload.instantiate() as Cloth
	cloth.laundry_type = cloth_type
	cloth.laundry_logic_color = color
	cloth.visible_color = visible_color
	
	return cloth

func spawn_random_cloth(cloth_color = "Any", cloth_type = "Any"):
	var cloth_type_index
	var color_index
	if cloth_type == "Any":
		cloth_type_index = randi_range(0, cloth_types.size()-1)
	else:
		cloth_type_index = cloth_types.find(cloth_type)
		
	if cloth_color == "Any":
		color_index = randi_range(0, max_color-1)
		if color_index == max_color - 1:
			color_index = randi_range(0, max_color-1)
	else:
		color_index = colors.find(cloth_color)
	
	return spawn_cloth(color_index, cloth_type_index)

func spawn_customer(cloth_color = "Any", cloth_type = "Any"):
	var customer = CUSTOMER.instantiate()
	var cloth = spawn_random_cloth(cloth_color, cloth_type)
	
	customer.cloth_i_came_with = cloth
	customer.laundry_color = cloth.laundry_logic_color
	customer.laundry_type = cloth.laundry_type
	
	customers_storage.add_child(customer)
	customer.global_position = global_position + Vector2(0, randf_range(-300,300))
	customer.visible_color = cloth.visible_color
	customer.item_placement_area = item_placement_area
	customer.item_placement_desk_mark = item_placement_desk_mark
	customer.waiting_area = waiting_area
	customer.nav_region = nav_region

func _add_waves_level1():
	pass

func _ready():
	pass#spawn_customer()
	#spawn_customer()
	#spawn_customer()
	#spawn_customer()
	#spawn_customer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
