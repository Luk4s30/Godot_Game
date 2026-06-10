extends Control
@onready var btn_graj = %GRAJ
@onready var btn_wyjdz = %WYJDZ
@onready var btn_ustawienia = %USTAWIENIA
@onready var btn_reset = %RESET
@onready var btn_garaz = %GARAZ
@onready var btn_powrot = %POWROT
@onready var btn_powrotM = %POWROTM
@onready var btn_mapa1 = %Mapa1
@onready var btn_mapa2 = %Mapa2
@onready var btn_mapa3 = %Mapa3
@onready var btn_mapa1W = %Mapa1W
@onready var btn_mapa2W = %Mapa2W
@onready var btn_mapa3W = %Mapa3W
@onready var music_slider = %music_slider
@onready var sfx_slider = %sfx_slider

func _ready():
	music_slider.value = Global.game_data["music_vol"]
	sfx_slider.value = Global.game_data["sfx_vol"]
	btn_graj.wcisnieto.connect(_on_graj_wcisnieto)
	btn_wyjdz.wcisnieto.connect(_on_wyjdz_wcisnieto)
	btn_ustawienia.wcisnieto.connect(_on_ustawienia_wcisnieto)
	btn_reset.wcisnieto.connect(_on_reset_wcisnieto)
	btn_garaz.wcisnieto.connect(_on_garaz_wcisnieto)
	btn_powrot.wcisnieto.connect(_on_powrot_wcisnieto)
	btn_powrotM.wcisnieto.connect(_on_powrotM_wcisnieto)

func _on_graj_wcisnieto():
	get_tree().change_scene_to_file("res://interfejs/menu/mapy.tscn")

func _on_wyjdz_wcisnieto():
	close_game()
	
func _on_ustawienia_wcisnieto():
	$MainMenu.hide()
	$Ustawienia.show()
	
func _on_reset_wcisnieto():
	Global.save_best_time("Tor",999999.0)
	Global.save_best_time("Las",999999.0)
	Global.save_best_time("Park",999999.0)

func _on_garaz_wcisnieto():
	get_tree().change_scene_to_file("res://interfejs/menu/garaz.tscn")

func _on_powrot_wcisnieto():
	$MainMenu.show()
	$Ustawienia.hide()

func _on_powrotM_wcisnieto():
	$MainMenu.show()
	$Mapy.hide()

func close_game():
	get_tree().quit()

func _on_MusicSlider_value_changed(value):
	Global.game_data["music_vol"] = value
	Global.apply_volume()
	Global.save_data_muzyka()

func _on_SFXSlider_value_changed(value):
	Global.game_data["sfx_vol"] = value
	Global.apply_volume()
	Global.save_data_muzyka()
