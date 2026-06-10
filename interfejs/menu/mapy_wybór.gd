extends Control

@export_group("Dane Map")
@export var map_names: Array[String] = ["Tor", "Las", "Park"]
@export var map_ids: Array[String] = ["tor_treningowy", "wies", "pustynia"] 
@export var map_images: Array[Texture2D] 

@export_group("Sceny Gry")
@export var race_scenes: Array[PackedScene]       
@export var time_trial_scenes: Array[PackedScene] 

@export_group("Kolory UI")
@export var active_color: Color = Color("ff9900")
@export var inactive_color: Color = Color("ffffff")

@onready var map_buttons_container = %mapy_but 
@onready var preview_texture = %zdj
@onready var map_name_label = %nazwa
@onready var btn_race = %"wyścig"
@onready var btn_time_trial = %czasowka
@onready var btn_start = %start
@onready var btn_back = %powrot

var current_map_index: int = 0
var current_mode: String = "race" 

var best_time

func _ready():
	setup_connections()
	update_visuals()
	update_mode_buttons()

func setup_connections():
	btn_race.wcisnieto.connect(_on_mode_changed.bind("race"))
	btn_time_trial.wcisnieto.connect(_on_mode_changed.bind("czas"))
	
	btn_start.wcisnieto.connect(_on_start_pressed)
	btn_back.wcisnieto.connect(_on_back_pressed)
	
	var map_buttons = map_buttons_container.get_children()
	for i in range(map_buttons.size()):
		var button = map_buttons[i]
		if button.has_signal("wcisnieto"):
			button.wcisnieto.connect(_on_map_selected.bind(i))
		else:
			button.pressed.connect(_on_map_selected.bind(i))

func _on_map_selected(index: int):
	if index == current_map_index: return
	
	current_map_index = index
	
	var tween = create_tween()
	tween.tween_property(%Panel2, "modulate:a", 0.0, 0.1)
	tween.tween_callback(update_visuals)
	tween.tween_property(%Panel2, "modulate:a", 1.0, 0.2)

func _on_mode_changed(new_mode: String):
	current_mode = new_mode
	update_mode_buttons()

func update_visuals():
	if map_images.size() > current_map_index:
		preview_texture.texture = map_images[current_map_index]
	
	if map_names.size() > current_map_index:
		map_name_label.text = map_names[current_map_index]
		best_time = Global.load_best_time(map_names[current_map_index])
		
		if best_time == 999999.0:
			%rekord.text = "Rekord: --:--"
		else:
			%rekord.text = "Rekord: "+"%.2f" % (best_time)

func update_mode_buttons():
	if current_mode == "race":
		btn_race.modulate = active_color
		btn_time_trial.modulate = inactive_color
	else:
		btn_race.modulate = inactive_color
		btn_time_trial.modulate = active_color

func _on_start_pressed():
	var scene_to_load: PackedScene = null
	
	if current_mode == "race":
		if current_map_index < race_scenes.size():
			scene_to_load = race_scenes[current_map_index]
	elif current_mode == "czas":
		if current_map_index < time_trial_scenes.size():
			scene_to_load = time_trial_scenes[current_map_index]
	
	if scene_to_load:
		
		Global.mapa = map_names[current_map_index]
		Global.tryb = current_mode
		
		Global.graj_muzyka_gra()
		
		get_tree().change_scene_to_packed(scene_to_load)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://interfejs/menu/interfejs.tscn")
