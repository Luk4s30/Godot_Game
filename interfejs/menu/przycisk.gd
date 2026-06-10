extends MarginContainer

@export var tekst: String = "START":
	set(value):
		tekst = value
		_aktualizuj_tekst()

@onready var labele = [
	$"label-zolty",
	$"label-niebieski",
	$"label-czerwony",
	$"label-bialy"
]
@onready var button = $przycisk
@onready var klik = $KlikAnimacja

signal wcisnieto

var czy_animowac = false 
var czas = 0.0
var predkosc = 3.0
var amplituda = 3.0
var bazy_rozmiarow = []

func _ready():
	for l in labele:
		if l.label_settings:
			l.label_settings = l.label_settings.duplicate()
			bazy_rozmiarow.append(l.label_settings.outline_size)
		else:
			bazy_rozmiarow.append(0)

	_aktualizuj_tekst()
	_ukryj_kolory()
	button.mouse_entered.connect(_pokaz_kolory)
	button.mouse_exited.connect(_ukryj_kolory)
	button.pressed.connect(_on_pressed)

func _process(delta: float):
	if czy_animowac:
		czas += delta * predkosc
		var fala_nieb = sin(czas + 1.0) * amplituda
		$"label-niebieski".label_settings.outline_size = bazy_rozmiarow[1] + fala_nieb
		var fala_czer = sin(czas + 2.0) * amplituda
		$"label-czerwony".label_settings.outline_size = bazy_rozmiarow[2] + fala_czer
		var fala_zolty = sin(czas) * amplituda
		$"label-zolty".label_settings.outline_size = bazy_rozmiarow[0] + fala_zolty

func _aktualizuj_tekst():
	if labele == null:
		return 
	for l in labele:
		l.text = tekst

func _pokaz_kolory():
	$"label-czerwony".show()
	$"label-niebieski".show()
	$"label-zolty".show()
	czy_animowac = true

func _ukryj_kolory():
	$"label-czerwony".hide()
	$"label-niebieski".hide()
	$"label-zolty".hide()
	czy_animowac = false

	if bazy_rozmiarow.size() > 0:
		$"label-zolty".label_settings.outline_size = bazy_rozmiarow[0]
		$"label-niebieski".label_settings.outline_size = bazy_rozmiarow[1]
		$"label-czerwony".label_settings.outline_size = bazy_rozmiarow[2]

func _on_pressed():
	klik.play("klik")
	$"klik".play()
	await klik.animation_finished
	wcisnieto.emit()
