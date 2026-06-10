extends CharacterBody2D

#Ustawienia do inspektora
@export_category("AI Settings")
@export var path_node: Path2D 
@export var look_ahead_distance: float = 300.0
@export var avoidance_max_strength: float = 2.0 
@export var max_lane_offset: float = 50.0
@export var lane_change_interval: float = 3.0

@onready var sensors = [
	{ "ray": $sensory/RayL2,   "force": 0.5 },
	{ "ray": $sensory/RayL1,   "force": 1.0 },
	{ "ray": $sensory/RayFront,"force": 0.0 },
	{ "ray": $sensory/RayR1,   "force": -1.0 },
	{ "ray": $sensory/RayR2,   "force": -0.5 }
]

#FIZYKA SAMOCHODU
var wheel_base = 70
var drag = -0.001
var braking = -450
var max_speed_reversed = 250
var slip_speed_start = 200.0
var slip_speed_end = 450.0
var traction_slow = 0.7

#STATYSTYKI PRZECIWNIka
@export var engine_power = 1000  
@export var steering_angle = 17
@export var traction_fast = 0.05 
@export var friction = -0.8
@export var road_layers: Array[TileMapLayer]

#Zmienne wewnętrzne
var acceleration = Vector2.ZERO
var steer_direction = 0.0
var surface_modifier = 1.0
var debug_target = Vector2.ZERO 
var current_lane_offset: float = 0.0
var target_lane_offset: float = 0.0
var lane_timer: float = 0.0

# Efekty
@onready var particle_left = $dymL
@onready var particle_right = $dymP
@onready var silnik_sfx = $SilnikSFX
@onready var pisk_sfx = $PiskSFX
var min_pitch = 0.8 
var max_pitch = 2.5
var min_drift_speed = 100.0
var drift_angle_start = 20.0

var aktualne_okrazenie: int = 1
var ostatni_checkpoint: int = -1 
var max_checkpointow: int = 0

#DEBUG
#func _process(_delta):
	#queue_redraw()
	
func _ready():
	var dostepne_auta = Global.lista_aut.duplicate()

	if Global.wybrane_auto and Global.wybrane_auto in dostepne_auta:
		dostepne_auta.erase(Global.wybrane_auto)
	
	if dostepne_auta.size() > 0:
		var wylosowane = dostepne_auta.pick_random()
		zastosuj_statystyki(wylosowane)
	else:
		if Global.lista_aut.size() > 0:
			zastosuj_statystyki(Global.lista_aut[0])

func _physics_process(delta):
	acceleration = Vector2.ZERO
	check_surface()
	calculate_ai_logic() 
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	obsluga_dymu()
	obsluga_dzwieku()
	move_and_slide()
	obsluga_kolizji()
	
func is_point_on_road(global_point: Vector2) -> bool:
	for layer in road_layers:
		if layer == null: continue
		var map_pos = layer.local_to_map(layer.to_local(global_point))
		if layer.get_cell_source_id(map_pos) != -1:
			return true 
	return false 


func calculate_ai_logic():
	#zmiana lini jazdy
	lane_timer += get_physics_process_delta_time()
	if lane_timer > lane_change_interval:
		lane_timer = 0.0
		target_lane_offset = randf_range(-max_lane_offset, max_lane_offset)
	current_lane_offset = lerp(current_lane_offset, target_lane_offset, 0.02)

	#obliczanie punktu celu i pozycji
	var local_car_pos = path_node.to_local(global_position)
	var current_offset = path_node.curve.get_closest_offset(local_car_pos)
	var target_dist_offset = current_offset + look_ahead_distance
	var target_transform = path_node.curve.sample_baked_with_rotation(target_dist_offset, true)
	var center_pos = target_transform.origin
	var offset_vector = target_transform.y * current_lane_offset
	var final_local_pos = center_pos + offset_vector
	var global_target = path_node.to_global(final_local_pos)
	
	# Debugowanie
	debug_target = global_target
	
	# Obliczamy kąt do celu
	var local_target_dir = to_local(global_target)
	var desired_angle = local_target_dir.angle()
	
	#omijanie przeszkód
	var avoidance_turn = 0.0
	var rays_hit_count = 0
	
	for sensor in sensors:
		var ray = sensor["ray"]
		var base_force = sensor["force"]
		var is_danger = false
		var danger_factor = 0.0 
		
		#KOLIZJA
		if ray.is_colliding():
			is_danger = true
			var hit_point = ray.get_collision_point()
			var dist2 = ray.global_position.distance_to(hit_point)
			var max_len = ray.target_position.length()
			danger_factor = clamp(1.0 - (dist2 / max_len), 0.0, 1.0)
			
		#TRAWA
		else:
			var tip_position = ray.to_global(ray.target_position)
			if not is_point_on_road(tip_position):
				is_danger = true
				danger_factor = 0.8 
		
		#REAKCJA
		if is_danger:
			rays_hit_count += 1
			if base_force == 0.0:
				var turn_power = 1.5 * danger_factor 
				if steer_direction > 0: avoidance_turn += turn_power
				else: avoidance_turn -= turn_power
				acceleration *= (1.0 - (0.7 * danger_factor))
			else:
				avoidance_turn += base_force * danger_factor

	if rays_hit_count > 0:
		avoidance_turn = clamp(avoidance_turn, -avoidance_max_strength, avoidance_max_strength)
	
	var final_angle = desired_angle + avoidance_turn
	var max_steer_rad = deg_to_rad(steering_angle)
	steer_direction = clamp(final_angle, -max_steer_rad, max_steer_rad)
	
	if rays_hit_count >= 2 or abs(steer_direction) > deg_to_rad(20):
		acceleration = transform.x * (engine_power * 0.5) * surface_modifier
	else:
		acceleration = transform.x * engine_power * surface_modifier

#sterowanie
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	var slip_factor = smoothstep(slip_speed_start, slip_speed_end, velocity.length())
	var traction = lerp(traction_slow, traction_fast, slip_factor)
	
	var d = new_heading.dot(velocity.normalized())
	if d > 0: velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0: velocity = -new_heading * min(velocity.length(), max_speed_reversed)
	rotation = new_heading.angle()

func apply_friction():
	if velocity.length() < 5: velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

#sprawdzamie powierzchni
func check_surface():
	var found_road = false
	for layer in road_layers:
		if layer == null: continue
		var map_pos = layer.local_to_map(layer.to_local(global_position))
		if layer.get_cell_source_id(map_pos) != -1:
			found_road = true
			break
	surface_modifier = 1.0 if found_road else 0.3

#efekt dymu
func obsluga_dymu():
	if velocity.length() < min_drift_speed:
		_set_emitting(false); return
	var angle_diff = abs(rad_to_deg(transform.x.angle_to(velocity.normalized())))
	_set_emitting(angle_diff > drift_angle_start and angle_diff < 100.0)

func _set_emitting(state):
	if particle_left: particle_left.emitting = state
	if particle_right: particle_right.emitting = state

#dzwienk
func obsluga_dzwieku():
	if silnik_sfx:
		var pitch = min_pitch + (velocity.length() / 1200.0)
		silnik_sfx.pitch_scale = clamp(pitch, min_pitch, max_pitch)
	if pisk_sfx:
		if particle_left.emitting and !pisk_sfx.playing: pisk_sfx.play()
		elif !particle_left.emitting and pisk_sfx.playing: pisk_sfx.stop()

func _draw():
	if debug_target != Vector2.ZERO:
		draw_line(Vector2.ZERO, to_local(debug_target), Color.PURPLE, 5.0)
		draw_circle(to_local(debug_target), 20.0, Color.PURPLE)
		
#kolizje
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

func zalicz_checkpoint(nr: int, meta: bool):
	if nr == ostatni_checkpoint + 1:
		ostatni_checkpoint = nr
		print(name, " zaliczył punkt ", nr)
	
	elif meta and ostatni_checkpoint == max_checkpointow:
		aktualne_okrazenie += 1
		ostatni_checkpoint = 0
		print(name, " NOWE OKRĄŻENIE! ", aktualne_okrazenie)

func zastosuj_statystyki(dane: Resource):
	engine_power = dane.moc
	steering_angle = dane.skret
	traction_fast = dane.przyczepnosc_drift 
	friction = dane.tarcie
	if has_node("Sprite2D"):
		$Sprite2D.texture = dane.tekstura
