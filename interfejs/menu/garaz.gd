extends Control

#UI
@onready var podglad = %Zdjecie
@onready var nazwa_lbl = %Nazwa
@onready var pasek_mocy = %PasekMocy      
@onready var pasek_skretu = %PasekSkretu   
@onready var pasek_przyczepnosci = %PasekPrzyczepnosci
@onready var karta = %kontenerKarty
@onready var znacznik = %ZnacznikWyboru

#przyciski
@onready var btn_lewo = %Lewo
@onready var btn_prawo = %Prawo
@onready var btn_wybierz = %Wybierz
@onready var btn_powrot = %Powrot

var obecny_indeks = 0
var czy_animuje = false
var pozycja_startowa: Vector2

func _ready():
	obecny_indeks = Global.game_data["selected_car"]
	
	#konfiguracja karty
	if karta:
		karta.pivot_offset = karta.size / 2
		pozycja_startowa = karta.position
	
	_aktualizuj_widok()
	
	btn_lewo.wcisnieto.connect(_inicjuj_zmiane.bind(1))
	btn_prawo.wcisnieto.connect(_inicjuj_zmiane.bind(-1))
	btn_wybierz.wcisnieto.connect(_wybierz)
	btn_powrot.wcisnieto.connect(_powrot)

func _inicjuj_zmiane(kierunek):
	if czy_animuje: return
	czy_animuje = true
	
	#animacja
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var offset_lotu = 1000 
	var cel_x = pozycja_startowa.x + (-offset_lotu if kierunek == 1 else offset_lotu)
	var rotacja = -15 if kierunek == 1 else 15
	
	tween.set_parallel(true)
	tween.tween_property(karta, "position:x", cel_x, 0.3)
	tween.tween_property(karta, "rotation_degrees", rotacja, 0.3)
	tween.tween_property(karta, "modulate:a", 0.0, 0.2)
	tween.set_parallel(false)
	
	tween.tween_callback(func():
		_oblicz_nowy_indeks(kierunek)
		_aktualizuj_widok()
		var start_druga_strona = pozycja_startowa.x + (offset_lotu if kierunek == 1 else -offset_lotu)
		karta.position.x = start_druga_strona
		karta.rotation_degrees = -rotacja
	)
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) # Efekt "sprężystości" przy lądowaniu
	tween.set_parallel(true)
	tween.tween_property(karta, "position:x", pozycja_startowa.x, 0.4)
	tween.tween_property(karta, "rotation_degrees", 0.0, 0.4) 
	tween.tween_property(karta, "modulate:a", 1.0, 0.3) 
	tween.set_parallel(false)
	tween.tween_callback(func(): czy_animuje = false)

func _oblicz_nowy_indeks(kierunek):
	obecny_indeks -= kierunek
	if obecny_indeks >= Global.lista_aut.size():
		obecny_indeks = 0
	elif obecny_indeks < 0:
		obecny_indeks = Global.lista_aut.size() - 1

func _aktualizuj_widok():
	var auto = Global.lista_aut[obecny_indeks]
	
	nazwa_lbl.text = auto.nazwa
	podglad.texture = auto.tekstura
	pasek_mocy.value = auto.moc
	pasek_skretu.value = auto.skret
	pasek_przyczepnosci.value = auto.przyczepnosc_drift
	
	if Global.wybrane_auto == auto:
		znacznik.visible = true
		znacznik.modulate = Color.WHITE
	else:
		znacznik.visible = false

func _wybierz():
	Global.game_data["selected_car"] = obecny_indeks
	Global.save_data_muzyka()
	if Global.wybrane_auto == Global.lista_aut[obecny_indeks]:
		_animuj_juz_wybrane()
		return

	Global.wybrane_auto = Global.lista_aut[obecny_indeks]
	
	_aktualizuj_widok()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var start_y = pozycja_startowa.y
	tween.tween_property(karta, "position:y", start_y - 20, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(karta, "position:y", start_y, 0.3).set_trans(Tween.TRANS_BOUNCE)
	znacznik.scale = Vector2(0.4, 0.4) 
	znacznik.modulate.a = 0.0
	
	var tween_znacznika = create_tween()
	tween_znacznika.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_znacznika.set_parallel(true)
	tween_znacznika.tween_property(znacznik, "scale", Vector2(0.2, 0.2), 0.3)
	tween_znacznika.tween_property(znacznik, "modulate:a", 1.0, 0.2)

func _animuj_juz_wybrane():

	var tween = create_tween()
	tween.tween_property(karta, "rotation_degrees", -5, 0.05)
	tween.tween_property(karta, "rotation_degrees", 5, 0.05)
	tween.tween_property(karta, "rotation_degrees", 0, 0.05)
	
	
func _powrot():
	get_tree().change_scene_to_file("res://interfejs/menu/interfejs.tscn")
