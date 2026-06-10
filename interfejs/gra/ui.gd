extends Control

@onready var timer_l = %LabelTimer
@onready var best_l = %BestTime
@onready var pierwszy = %pierwszy
@onready var drugi = %drugi
@onready var trzeci = %trzeci

var mapa = Global.mapa

var best_time = Global.load_best_time(mapa)
var start_time = 0
var czy_jedzie = false

var lap = 1

func _ready() -> void:
	print(mapa)
	print(best_time)
	timer_l.show()
	timer_l.text = "--:--"
	if best_time == 999999.0:
		best_l.text = "--:--"
	else:
		best_l.text = "%.2f" % (best_time)
		
	Global.przekroczono_linie.connect(_obsluga_mety)

func _process(_delta: float) -> void:
	if czy_jedzie:
		var obecny_czas = Time.get_ticks_msec() - start_time
		timer_l.text = "%.2f" % (obecny_czas / 1000.0)

func _obsluga_mety():
	if not czy_jedzie:
		start_time = Time.get_ticks_msec()
		czy_jedzie = true
	else:
		var czas_okrazenia = snapped(((Time.get_ticks_msec() - start_time)/1000.0), 0.01)
		on_lap_finished(czas_okrazenia)
		start_time = Time.get_ticks_msec()
		
func on_lap_finished(current_lap_time: float):
	trzeci.text = drugi.text
	drugi.text = pierwszy.text
	pierwszy.text = "" + str(lap) + ": " + str(current_lap_time)
	lap=lap+1
	
	if current_lap_time < best_time:
		Global.save_best_time(mapa, current_lap_time)
		best_time = current_lap_time
		best_l.text = "%.2f" % (best_time)
		print(current_lap_time)
		print(best_time)
		print("zapis")
