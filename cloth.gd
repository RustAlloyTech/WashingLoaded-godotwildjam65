extends RigidBody2D
class_name Cloth

@export var is_bandaid : bool = false
@export var laundry_logic_color : String # White / Blue / Red 
@export var laundry_type : String  # Jeans / Shirt / Socks
@onready var spritesheet_dirt: Sprite2D = $SpritesheetDirt

@export var visible_color : Color
@export var weight = 5

var mashed_color = false
var dirty = true
var inside_washing_machine = false
var is_held = false

var has_yoinker = false

func _ready(): 
	if is_bandaid:
		return
	modulate = visible_color

# I did not know yet you can cast "cloth as Cloth" and then if it is null, 
# then it is not a cloth. 
# if cloth as Cloth != null:
# Used 
# if cloth.has_method("i_am_a_cloth"): 
# instead... somewhere
func i_am_a_cloth():
	pass

func am_i_dirty():
	return dirty
	
func am_i_mashed():
	return mashed_color

func washing_cycle_complete(washed_with_different_colors : bool = false):
	dirty = false
	spritesheet_dirt.visible = false
	
	
	
	
	
	
	
	
	
	
	
	
