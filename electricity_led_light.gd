extends Sprite2D
class_name ElectricityLedLight

func turn_on():
	modulate = Color(1,1,1,1)
	
func turn_off():
	modulate = Color(0.5,0.5,0.5,1)
	
func turn_red():
	modulate = Color(1,0.2,0.2,1)
