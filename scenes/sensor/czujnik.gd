extends Area2D


func _on_area_entered(area):
	$Led.on = true

func _on_area_exited(area):
	$Led.on = false
