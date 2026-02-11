extends CharacterBody2D
## Avion en papier contrôlé par le joueur.
## Machine à états : FLYING → LOOPING → DIVING → GROUNDED → RISING → FLYING

enum State { FLYING, LOOPING, DIVING, GROUNDED, RISING }

# --- Paramètres ajustables depuis l'éditeur ---
@export_group("Vol")
@export var flight_altitude := 180.0          ## Hauteur de croisière (depuis le haut)
@export var bob_amplitude := 12.0             ## Amplitude du balancement vertical
@export var bob_frequency := 2.5              ## Fréquence du balancement

@export_group("Plongeon")
@export var loop_duration := 0.5              ## Durée du looping (secondes)
@export var dive_speed := 500.0               ## Vitesse de descente
@export var rise_speed := 200.0               ## Vitesse de remontée

@export_group("Timeline")
@export var timeline_y := 560.0               ## Position Y de la barre de timeline

# --- Signaux ---
signal dive_landed                             ## Émis quand l'avion touche la timeline
signal returned_to_flight                      ## Émis quand l'avion revient en vol

# --- Références ---
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var flap_sound: AudioStreamPlayer2D = $FlapSound
@onready var dive_sound: AudioStreamPlayer2D = $DiveSound

# --- État interne ---
var state := State.FLYING
var time_alive := 0.0
var loop_timer := 0.0
var loop_start_rotation := 0.0
var _can_dive := true


func _ready() -> void:
	Global.player = self
	position.y = flight_altitude
	velocity = Vector2.ZERO
	add_to_group("players")


func _physics_process(delta: float) -> void:
	time_alive += delta

	match state:
		State.FLYING:
			_fly(delta)
		State.LOOPING:
			_loop(delta)
		State.DIVING:
			_dive(delta)
		State.GROUNDED:
			velocity = Vector2.ZERO
		State.RISING:
			_rise(delta)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if state == State.FLYING and _can_dive:
		if event.is_action_pressed("dive"):
			_start_loop()


# === ÉTATS ===

func _fly(_delta: float) -> void:
	# Balancement doux sinusoïdal
	var bob := sin(time_alive * bob_frequency) * bob_amplitude
	position.y = flight_altitude + bob

	# Légère rotation selon le mouvement vertical
	rotation = deg_to_rad(sin(time_alive * bob_frequency) * 5.0)

	velocity = Vector2.ZERO
	sprite.play("fly")


func _start_loop() -> void:
	state = State.LOOPING
	loop_timer = 0.0
	loop_start_rotation = rotation
	_can_dive = false
	if flap_sound:
		flap_sound.play()


func _loop(delta: float) -> void:
	loop_timer += delta
	var progress := clampf(loop_timer / loop_duration, 0.0, 1.0)

	# Rotation complète de 360°
	rotation = loop_start_rotation + (progress * TAU)

	# Léger mouvement vers le haut pendant le loop
	velocity.y = -80.0 * (1.0 - progress)

	# Transition vers le plongeon
	if progress >= 1.0:
		state = State.DIVING
		rotation = deg_to_rad(60.0)
		sprite.play("dive")
		if dive_sound:
			dive_sound.play()


func _dive(_delta: float) -> void:
	velocity.y = dive_speed
	# Pointer vers le bas
	rotation = lerp(rotation, deg_to_rad(70.0), 0.1)

	# Touche la barre de timeline
	if position.y >= timeline_y:
		position.y = timeline_y
		_land()


func _land() -> void:
	state = State.GROUNDED
	velocity = Vector2.ZERO
	rotation = 0.0
	sprite.play("idle")
	dive_landed.emit()


func _rise(_delta: float) -> void:
	velocity.y = -rise_speed
	rotation = lerp(rotation, deg_to_rad(-15.0), 0.05)

	if position.y <= flight_altitude:
		position.y = flight_altitude
		rotation = 0.0
		state = State.FLYING
		_can_dive = true
		sprite.play("fly")
		returned_to_flight.emit()


# === API publique ===

## Appelé après fermeture du popup pour reprendre le vol
func resume_flight() -> void:
	state = State.RISING


## Vérifie si le joueur est en vol (pour la timeline)
func is_flying() -> bool:
	return state == State.FLYING
