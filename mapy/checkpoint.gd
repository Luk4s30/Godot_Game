extends Area2D

@export var numer_checkpointa: int = 0
@export var czy_to_meta: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("zalicz_checkpoint"):
		body.zalicz_checkpoint(numer_checkpointa, czy_to_meta)
