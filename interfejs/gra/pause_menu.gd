extends Control

var pause_toggle = false

func _ready() -> void:
	self.visible = false
	%Resume.wcisnieto.connect(resume)
	%Restart.wcisnieto.connect(reset)
	%"Main menu".wcisnieto.connect(menu)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_and_unpause()
		
func pause_and_unpause():
	pause_toggle = !pause_toggle
	get_tree().paused = pause_toggle
	self.visible = pause_toggle

func resume():
	pause_and_unpause()

func reset():
	pause_and_unpause()
	get_tree().reload_current_scene()

func menu():
	pause_and_unpause() 
	Global.graj_muzyka_menu()
	get_tree().change_scene_to_file("res://interfejs/menu/interfejs.tscn")
