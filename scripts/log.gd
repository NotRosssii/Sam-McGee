extends Node3D

@export var log_id: String = ""  # Optional: Use this to identify logs if needed
var player_near = false

# Called every frame to check for interaction
func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("interact"):  # Default key is "E"
		print("Player collected the log:", log_id)
		queue_free()  # Removes the log from the scene


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":  # Check if the player triggered the log
		print("Player entered the area of log:", log_id)
		player_near = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":  # Check if the player left the log
		print("Player left the area of log:", log_id)
		player_near = false
