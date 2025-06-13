extends Node2D

# Configuration
@export var float_amplitude := 5.0  # How far up/down
@export var float_speed := 3.0      # Speed of floating

var original_y := 0.0
var time := 0.0

func _ready():
	original_y = position.y

func _process(delta):
	time += delta * float_speed
	position.y = original_y + sin(time) * float_amplitude
