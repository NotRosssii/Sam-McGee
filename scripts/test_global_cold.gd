extends Node

var in_warmth_zone = false
@export var max_cold: float = 100.0
var current_cold: float = max_cold
@export var cold_decrease_rate: float = 1.0
@export var cold_increase_rate: float = 3.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_warmth_zone:
		current_cold = min(current_cold + cold_increase_rate * delta, max_cold)
		print(current_cold)
	else:
		current_cold = max(current_cold - cold_decrease_rate * delta, 0)
		print(current_cold)
	if current_cold <= 90:
		print("Player is fucking freezing!")
		print(current_cold)
