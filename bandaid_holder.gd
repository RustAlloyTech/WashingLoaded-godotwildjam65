extends Node2D
class_name BandaidHolder


@onready var bandaid_holder_inner = $BandaidHolderInner
const BANDAID = preload("res://Clothes/bandaid.tscn")
@onready var animation_player = $AnimationPlayer
@onready var blink_player = $BlinkPlayer



# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("bandaid_floating")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bandaid_holder_inner.get_child_count() == 0:
		var bandaid = BANDAID.instantiate()
		bandaid_holder_inner.add_child(bandaid)


func _blink_it():
	blink_player.play("blink")
