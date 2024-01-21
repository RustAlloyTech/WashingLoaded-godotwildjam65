extends Area2D



func _on_body_entered(body):
	#print(body)
	var cloth = body as Cloth
	#print(cloth)
	if cloth != null:
		SignalBus.signal_clean_cloth_ready_for_pickup.emit(cloth)
