extends Area3D

class_name warmth

func _on_area_entered(area):
	if area.is_in_group("Player"):  
		emit_signal("entered_warmth_zone") 
		print("Player entered the warmth zone!")  # Debug 

func _on_area_exited(area):
	if area.is_in_group("Player"):  
		emit_signal("exited_warmth_zone") 
		print("Player exited the warmth zone!")  # Debug 
		
