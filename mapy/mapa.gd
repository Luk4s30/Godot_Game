extends Node2D

@onready var gracz = $Car
@onready var bot = $ai_car
@onready var checkpoint = $Checkpoint

@export var liczba_okr = 3

var checkpointy = []
var lista_aut = []

var koniec = false

func _ready():
	checkpointy = checkpoint.get_children()
	var max_index = checkpointy.size() - 1
	
	lista_aut = get_tree().get_nodes_in_group("car")
	
	print("Znaleziono aut: ", lista_aut.size())
	
	# 3. Konfigurujemy każde auto
	for auto in lista_aut:
		if "max_checkpointow" in auto:
			auto.max_checkpointow = max_index
			
	$Car.get_node("%UI_race").get_node("%okrLabel").text = "Okrążenie: 1/" + str(liczba_okr)
	$Car.get_node("%UI_race").get_node("%pozycja").text = "Pozycja: 1/" + str(lista_aut.size())

func _process(_delta):
	oblicz_ranking()

func oblicz_ranking():
	lista_aut.sort_custom(func(a, b):
		if a.aktualne_okrazenie != b.aktualne_okrazenie:
			return a.aktualne_okrazenie > b.aktualne_okrazenie
		if a.ostatni_checkpoint != b.ostatni_checkpoint:
			return a.ostatni_checkpoint > b.ostatni_checkpoint
		
		var nastepny_cp_index = a.ostatni_checkpoint + 1
		if nastepny_cp_index >= checkpointy.size():
			nastepny_cp_index = 0
			
		var cel = checkpointy[nastepny_cp_index].global_position
		
		var dystans_a = a.global_position.distance_to(cel)
		var dystans_b = b.global_position.distance_to(cel)
		
		return dystans_a < dystans_b
	)
	
	_aktualizuj_ui_dla_wszystkich()

func _aktualizuj_ui_dla_wszystkich():
	for i in range(lista_aut.size()):
		var auto = lista_aut[i]
		var pozycja = i + 1

		if auto.has_node("%UI_race"):
			auto.get_node("%UI_race").get_node("%okrLabel").text = "Okrążenie: " + str(auto.aktualne_okrazenie) + "/" + str(liczba_okr)
			auto.get_node("%UI_race").get_node("%pozycja").text = "Pozycja: " + str(pozycja) + "/" + str(lista_aut.size())
			if liczba_okr< auto.aktualne_okrazenie and !koniec:
				Global.can_drive = false
				auto.get_node("%UI_race").get_node("%EndScreen").show()
				auto.get_node("%UI_race").get_node("%wynik").text = "Zająłeś " + str(pozycja) + " miejsce!"
				auto.get_node("%UI_race").get_node("%okrLabel").hide()
				auto.get_node("%UI_race").get_node("%pozycja").hide()
				koniec = true
