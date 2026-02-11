extends CharacterBody2D

signal dive_landed
signal returned_to_flight

enum State { FLYING, DIVE_LOOP, DIVING_DOWN, HIDDEN, RISING, RISE_LOOP }

@export var loop_radius: float = 120.0
@export var loop_speed: float = 3.5
@export var dive_speed: float = 700.0
@export var rise_speed: float = 700.0
@export var bob_amplitude: float = 4.0
@export var bob_frequency: float = 0.4       # bien plus lent → serein
@export var bob_x_amplitude: float = 2.0     # léger mouvement horizontal
@export var bob_x_frequency: float = 0.25

@onready var sprite: AnimatedSprite2D = $Sprite

var state: State = State.FLYING
var _loop_center: Vector2
var _loop_angle: float
var _loop_swept: float
var _flight_y: float
var _flight_x: float
var _bob_time: float = 0.0
var _rise_target: Vector2
var _trail: CPUParticles2D


func _ready() -> void:
	_flight_y = position.y
	_flight_x = position.x
	_create_trail()


func _physics_process(delta: float) -> void:
	_update_trail_velocity()
	match state:
		State.FLYING:
			_process_flying(delta)
		State.DIVE_LOOP:
			_process_dive_loop(delta)
		State.DIVING_DOWN:
			_process_diving_down(delta)
		State.RISING:
			_process_rising(delta)
		State.RISE_LOOP:
			_process_rise_loop(delta)
		State.HIDDEN:
			pass


# ── Vol normal (balancement doux et lent) ────────────────────
func _process_flying(delta: float) -> void:
	_bob_time += delta

	# Mouvement vertical : vague lente
	var wave_y := sin(_bob_time * bob_frequency * TAU)
	# Mouvement horizontal : vague encore plus lente, déphasée
	var wave_x := sin(_bob_time * bob_x_frequency * TAU + 1.2)

	position.y = _flight_y + wave_y * bob_amplitude
	position.x = _flight_x + wave_x * bob_x_amplitude

	# Légère inclinaison qui suit le mouvement vertical
	rotation = wave_y * 0.03
	sprite.play("fly")

# ── Input ────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if state != State.FLYING:
		return
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed():
			start_dive()
	if event is InputEventKey:
		if event.is_pressed() and event.keycode != KEY_RIGHT:
			start_dive()


# ══════════════════════════════════════════════════════════════
#  PLONGEON  (looping 270° puis chute verticale)
# ══════════════════════════════════════════════════════════════
func start_dive() -> void:
	state = State.DIVE_LOOP
	_loop_center = position + Vector2(0, -loop_radius)
	_loop_angle = PI / 2.0
	_loop_swept = 0.0


func _process_dive_loop(delta: float) -> void:
	var step := loop_speed * delta
	_loop_swept += step
	_loop_angle -= step

	position = _loop_center + Vector2(cos(_loop_angle), sin(_loop_angle)) * loop_radius
	var tangent := Vector2(sin(_loop_angle), -cos(_loop_angle))
	rotation = tangent.angle()

	if _loop_swept >= PI * 1.5:
		state = State.DIVING_DOWN
		rotation = PI / 2.0


func _process_diving_down(delta: float) -> void:
	position.y += dive_speed * delta
	if position.y > get_viewport_rect().size.y + 150:
		state = State.HIDDEN
		visible = false
		_trail.emitting = false
		dive_landed.emit()


# ══════════════════════════════════════════════════════════════
#  REMONTÉE  (montée verticale puis looping 270°)
# ══════════════════════════════════════════════════════════════
func resume_flight() -> void:
	_rise_target = Vector2(_flight_x + loop_radius, _flight_y - loop_radius)
	position = Vector2(_rise_target.x, get_viewport_rect().size.y + 150)
	rotation = -PI / 2.0
	visible = true
	_trail.emitting = true
	state = State.RISING


func _process_rising(delta: float) -> void:
	position.y -= rise_speed * delta
	if position.y <= _rise_target.y:
		position = _rise_target
		_start_rise_loop()


func _start_rise_loop() -> void:
	state = State.RISE_LOOP
	_loop_center = position + Vector2(-loop_radius, 0)
	_loop_angle = 0.0
	_loop_swept = 0.0


func _process_rise_loop(delta: float) -> void:
	var step := loop_speed * delta
	_loop_swept += step
	_loop_angle -= step

	position = _loop_center + Vector2(cos(_loop_angle), sin(_loop_angle)) * loop_radius
	var tangent := Vector2(sin(_loop_angle), -cos(_loop_angle))
	rotation = tangent.angle()

	if _loop_swept >= PI * 1.5:
		position = Vector2(_flight_x, _flight_y)
		rotation = 0.0
		_bob_time = 0.0
		state = State.FLYING
		returned_to_flight.emit()


# ══════════════════════════════════════════════════════════════
#  TRAÎNÉE DE PARTICULES
# ══════════════════════════════════════════════════════════════
func _create_trail() -> void:
	_trail = CPUParticles2D.new()
	_trail.z_index = -1
	_trail.position = Vector2(-20, 0)
	add_child(_trail)

	_trail.emitting = true
	_trail.amount = 40
	_trail.lifetime = 0.6
	_trail.local_coords = false
	_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT

	# Vélocité initiale vers la gauche (sera ajustée dynamiquement)
	_trail.direction = Vector2(-1, 0)
	_trail.spread = 15.0
	_trail.initial_velocity_min = 80.0
	_trail.initial_velocity_max = 120.0

	# Gravité nulle
	_trail.gravity = Vector2.ZERO

	# Taille
	_trail.scale_amount_min = 3.0
	_trail.scale_amount_max = 5.0

	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 1.0))
	scale_curve.add_point(Vector2(1.0, 0.0))
	_trail.scale_amount_curve = scale_curve

	# Couleur : blanc 50% → transparent
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 0.5))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	_trail.color_ramp = gradient

	# Texture ronde
	var tex := GradientTexture2D.new()
	var circle_grad := Gradient.new()
	circle_grad.set_color(0, Color.WHITE)
	circle_grad.set_color(1, Color.TRANSPARENT)
	tex.gradient = circle_grad
	tex.width = 16
	tex.height = 16
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	_trail.texture = tex


## Ajuste la vélocité des particules selon l'état.
## En vol, la scène défile → on pousse les particules vers la gauche.
## En looping/plongeon, l'avion bouge réellement → vélocité réduite.
func _update_trail_velocity() -> void:
	match state:
		State.FLYING:
			# Compense le scroll de la timeline pour que la traînée
			# apparaisse derrière l'avion dans le monde
			var scroll_v: float = Global.scroll_speed * Global.time_scale
			_trail.initial_velocity_min = scroll_v * 0.6
			_trail.initial_velocity_max = scroll_v * 0.9
			_trail.direction = Vector2(-1, 0)
		State.DIVE_LOOP, State.RISE_LOOP:
			_trail.initial_velocity_min = 30.0
			_trail.initial_velocity_max = 60.0
		State.DIVING_DOWN:
			_trail.direction = Vector2(0, -1)
			_trail.initial_velocity_min = 80.0
			_trail.initial_velocity_max = 120.0
		State.RISING:
			_trail.direction = Vector2(0, 1)
			_trail.initial_velocity_min = 80.0
			_trail.initial_velocity_max = 120.0
