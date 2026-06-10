extends Node

var tryb = "wyscig"

signal przekroczono_linie

var can_drive = true

var lista_aut: Array[Samochod] = [
	preload("res://car/stats/czerwony.tres"),
	preload("res://car/stats/czarny.tres"),
	preload("res://car/stats/niebieski.tres"),
	preload("res://car/stats/zolty.tres")
]

var game_data = {
	"music_vol": 1.0,      
	"sfx_vol": 1.0,       
	"selected_car": 0    
}

# ZAPIS I ODCZYT CZASU OKRĄŻENIA
var mapa=""
const sciezka_zapisu_mapa = "user://best_lap.save"
var sciezka_menu = "res://assets/sound/background-music-159125.mp3"
var sciezka_gra = "res://assets/sound/DjPengu_loop.wav"
var music_player: AudioStreamPlayer
var sciezka_zapisu = "user://ustawienia_muzyka.save" 
var wybrane_auto: Samochod = lista_aut[0]

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "muzyka"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	load_data_muzyka()
	graj_muzyka_menu()
	wybrane_auto = lista_aut[game_data["selected_car"]]

#zapis i odczyt z pliku z muzyką i wyborem samochodu
func save_data_muzyka():
	var file = FileAccess.open(sciezka_zapisu, FileAccess.WRITE)
	file.store_var(game_data)

func load_data_muzyka():
	if FileAccess.file_exists(sciezka_zapisu):
		var file = FileAccess.open(sciezka_zapisu, FileAccess.READ)
		game_data = file.get_var()
		apply_volume()

func apply_volume():
	#MUZYKA
	var music_bus = AudioServer.get_bus_index("muzyka")
	if game_data["music_vol"] == 0:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(game_data["music_vol"]))
		
	#SFX
	var sfx_bus = AudioServer.get_bus_index("sfx")
	if game_data["sfx_vol"] == 0:
		AudioServer.set_bus_mute(sfx_bus, true)
	else:
		AudioServer.set_bus_mute(sfx_bus, false)
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(game_data["sfx_vol"]))

func graj_muzyka_menu():
	zmien_utwor("res://assets/sound/background-music-159125.mp3")
	
func graj_muzyka_gra():
	zmien_utwor("res://assets/sound/DjPengu_loop.wav")

func zmien_utwor(sciezka):
	var nowy_stream = load(sciezka)
	if music_player.stream != nowy_stream:
		music_player.stream = nowy_stream
		music_player.play()

func save_best_time(map_name: String, time: float):
	var all_records = _load_all_data()
	
	all_records[map_name] = time
	var file = FileAccess.open(sciezka_zapisu_mapa, FileAccess.WRITE)
	
	if file:
		file.store_var(all_records)
		file.close()

func load_best_time(map_name: String) -> float:
	var all_records = _load_all_data()
	print(all_records)
	
	if all_records.has(map_name):
		return all_records[map_name]
	else:
		return 999999.0

func _load_all_data() -> Dictionary:
	if not FileAccess.file_exists(sciezka_zapisu_mapa):
		return {} 
	
	var file = FileAccess.open(sciezka_zapisu_mapa, FileAccess.READ)
	if file:
		var data = file.get_var()
		if data is Dictionary:
			return data
	
	return {}
