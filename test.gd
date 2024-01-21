extends Node2D

@onready var spawner : CustomerSpawner = $Spawner

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(30):
		for y in range(20):
			var cloth = spawner.spawn_cloth(x % 4, y % 3)
			add_child(cloth)
			cloth.global_position = Vector2(x*70,y*70)
