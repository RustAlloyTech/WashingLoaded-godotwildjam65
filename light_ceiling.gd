extends PointLight2D
class_name LightCeiling

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = randf_range(1,600)
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func electricity_turned_off():
	timer.stop()
	visible = false
	
	
func electricity_turned_on():
	timer.start()
	visible = true
	

func _on_timer_timeout():
	animation_player.play("flicker")
