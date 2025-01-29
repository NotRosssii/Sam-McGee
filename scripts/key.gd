extends Node3D

@export var log_id: String = "" 
var player_near = false


func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("interact"):  # Default key is "E"
		print("Player collected the key:", log_id)
		queue_free()  


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":  
		print("Player entered the area of key:", log_id)
		player_near = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":  
		print("Player left the area of key:", log_id)
		player_near = false
