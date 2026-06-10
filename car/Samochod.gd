extends Resource
class_name Samochod

@export_group("Wygląd")
@export var nazwa: String
@export var tekstura: Texture2D

@export_group("Fizyka")
@export_range(800, 1200) var moc: int = 1000 
@export_range(10, 24) var skret: int = 17
@export_range(0.01, 0.1) var przyczepnosc_drift: float = 0.05
@export_range(-1.0, -0.5) var tarcie: float = -0.8
