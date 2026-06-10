extends Control

func _ready() -> void:
	self.show()
	get_tree().paused = true
	
	%Animacja.play("odliczanie_a")
	await %Animacja.animation_finished
	get_tree().paused = false
	await get_tree().create_timer(1.0).timeout
	self.hide()
	%swiatloZ.hide()
	%swiatloC.hide()
	%swiatloZ2.hide()
	%swiatloC2.hide()
	%swiatloZ3.hide()
	%swiatloC3.hide()
