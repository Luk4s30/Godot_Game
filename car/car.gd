extends CharacterBody2D
class_name Auto

#STAŁE
var wheel_base = 70
var drag = -0.001
var braking = -450
var max_speed_reversed = 250
var slip_speed_start = 200.0
var slip_speed_end = 450.0
var traction_slow = 0.7

#statystyki nadpisywane przez samochód
var engine_power = 1000  
var steering_angle = 17
var traction_fast = 0.05 
var friction = -0.8

var acceleration: Vector2 = Vector2.ZERO
var steer_direction: float = 0.0

var surface_modifier: float = 1.0 
@export var road_layers: Array[TileMapLayer] 

@onready var particle_left = $dymL
@onready var particle_right = $dymP
var min_drift_speed = 100.0      
var drift_angle_start = 20.0

@onready var silnik_sfx = $SilnikSFX
@onready var pisk_sfx = $PiskSFX

# Ustawienia dźwięku
var min_pitch = 0.8 
var max_pitch = 2.5

var aktualne_okrazenie: int = 1
var ostatni_checkpoint: int = -1 
var max_checkpointow: int = 0

func _ready():
	if Global.tryb=="race":
		%UI_race.show()
		%UI_time.hide()
	elif Global.tryb=="czas":
		%UI_race.hide()
		%UI_time.show()
	else:
		%UI_race.hide()
		%UI_time.hide()
	
	Global.can_drive = true
	
	# WCZYTYWANIE SAMOCHODU
	var wybrane = Global.wybrane_auto
	
	if wybrane:
		engine_power = wybrane.moc
		steering_angle = wybrane.skret
		traction_fast = wybrane.przyczepnosc_drift
		friction = wybrane.tarcie
		
		if has_node("Sprite2D"):
			$Sprite2D.texture = wybrane.tekstura
			
func _physics_process(delta):
	acceleration = Vector2.ZERO
	check_surface()
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	obsluga_dymu()
	obsluga_dzwieku()
	move_and_slide()
	obsluga_kolizji()
	
func zalicz_checkpoint(nr: int, meta: bool):
	if nr == ostatni_checkpoint + 1:
		ostatni_checkpoint = nr
		print(name, " zaliczył punkt ", nr)
	
	elif meta and ostatni_checkpoint == max_checkpointow:
		aktualne_okrazenie += 1
		ostatni_checkpoint = 0
		print(name, " NOWE OKRĄŻENIE! ", aktualne_okrazenie)

func get_input():
	if Global.can_drive:
		var turn = 0
		if Input.is_action_pressed("Right"):
			turn += 1
		if Input.is_action_pressed("Left"):
			turn -= 1
		
		steer_direction = turn * deg_to_rad(steering_angle)
		
		if Input.is_action_pressed("Foward"):
			acceleration = transform.x * engine_power * surface_modifier
		elif Input.is_action_pressed("Backward"):
			acceleration = transform.x * braking * surface_modifier
		else:
			acceleration = Vector2.ZERO

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	var slip_factor = smoothstep(slip_speed_start, slip_speed_end, velocity.length())
	var traction = lerp(traction_slow, traction_fast, slip_factor)
	var current_speed = velocity.length()
		
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.lerp(new_heading * current_speed, traction)
	if d < 0:
		velocity = -new_heading * min(current_speed, max_speed_reversed)
	rotation = new_heading.angle()

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

func check_surface():
	var found_road = false
	for layer in road_layers:
		if layer == null:
			continue
			
		var map_pos = layer.local_to_map(layer.to_local(global_position))
		var tile_id = layer.get_cell_source_id(map_pos)
		if tile_id != -1:
			found_road = true
			break
	
	if found_road:
		surface_modifier = 1.0  
	else:
		surface_modifier = 0.4

func obsluga_dymu():
	if velocity.length() < min_drift_speed:
		_set_emitting(false)
		return

	var facing_direction = transform.x
	var move_direction = velocity.normalized()
	var angle_diff = abs(rad_to_deg(facing_direction.angle_to(move_direction)))
	if angle_diff > drift_angle_start and angle_diff < 100.0:
		_set_emitting(true)
	else:
		_set_emitting(false)

func _set_emitting(state: bool):
	if particle_left and particle_left.emitting != state:
		particle_left.emitting = state
	if particle_right and particle_right.emitting != state:
		particle_right.emitting = state
		
func obsluga_dzwieku():
	var current_speed = velocity.length()
	var target_pitch = min_pitch + (current_speed / 1000.0)
	silnik_sfx.pitch_scale = clamp(target_pitch, min_pitch, max_pitch)

	if particle_left.emitting:
		if not pisk_sfx.playing:
			pisk_sfx.play()
	else:
		if pisk_sfx.playing:
			pisk_sfx.stop()

func obsluga_kolizji():
	if get_slide_collision_count() == 0:
		return
		
	var collision = get_slide_collision(0)
	var collider = collision.get_collider()
	var normal = collision.get_normal()

	var slide_velocity = velocity.slide(normal)
	
	if collider is CharacterBody2D:
		var push_force = 50.0 + (velocity.length() * 0.05)
		velocity = slide_velocity + (normal * push_force)
		velocity *= 0.95
		
	else:
		velocity = slide_velocity
		velocity += normal * 10.0
		velocity *= 0.90
