extends Area2D

func _on_start_body_entered(body: Node2D) -> void:
	if body.name == "Car": 
		Global.przekroczono_linie.emit()
