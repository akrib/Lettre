extends CharacterBody2D

signal dive_landed
signal returned_to_flight

enum State { FLYING, DIVE_LOOP, DIVING_DOWN, HIDDEN, RISING, RISE_LOOP }

@export var loop_radius: float = 120.0
@export var loop_speed: float = 3.5      # rad/s
@export var dive_speed: float = 700.0
@export var rise_speed: float = 700.0
@export var bob_amplitude: float = 6.0
@export var bob_frequency: float = 2.0

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


# ── Vol normal (léger balancement) ──────────────────────────
func _process_flying(delta: float) -> void:
	_bob_time += delta
	var wave := sin(_bob_time * bob_frequency * TAU)
	position.y = _flight_y + wave * bob_amplitude
	rotation = wave * 0.05


# ── Input : déclenche le plongeon ────────────────────────────
func _input(event: InputEvent) -> void:
	if state != State.FLYING:
		return
	if event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventKey:
		if event.is_pressed():
			start_dive()


# ══════════════════════════════════════════════════════════════
#  PLONGEON  (looping 270° puis chute verticale)
# ══════════════════════════════════════════════════════════════
#
#  Centre du cercle : au-dessus de l'avion
#  Départ angle π/2 (en bas du cercle) → sens horaire 270°
#  L'avion part vers l'avant en montant, boucle, et finit
#  orienté vers le bas à la verticale.
#
func start_dive() -> void:
	state = State.DIVE_LOOP
	_loop_center = position + Vector2(0, -loop_radius)
	_loop_angle = PI / 2.0
	_loop_swept = 0.0


func _process_dive_loop(delta: float) -> void:
	var step := loop_speed * delta
	_loop_swept += step
	_loop_angle -= step                       # sens horaire

	position = _loop_center + Vector2(cos(_loop_angle), sin(_loop_angle)) * loop_radius

	# Tangente sens horaire : (sin θ, −cos θ)
	var tangent := Vector2(sin(_loop_angle), -cos(_loop_angle))
	rotation = tangent.angle()

	if _loop_swept >= PI * 1.5:                # 270°
		state = State.DIVING_DOWN
		rotation = PI / 2.0                    # droit vers le bas


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
#
#  L'avion apparaît sous l'écran, monte en piqué.
#  Arrivé en position, il boucle 270° sens horaire :
#  Centre du cercle à sa gauche, départ angle 0 (à droite).
#  Il bascule vers la gauche et repart à l'horizontale.
#
func resume_flight() -> void:
	# Position de départ du looping de remontée :
	#   centre = (_flight_x,  _flight_y − R)
	#   avion  = centre + (R, 0)  →  (_flight_x + R,  _flight_y − R)
	_rise_target = Vector2(_flight_x + loop_radius, _flight_y - loop_radius)

	position = Vector2(_rise_target.x, get_viewport_rect().size.y + 150)
	rotation = -PI / 2.0                       # orienté vers le haut
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
	_loop_angle -= step                        # sens horaire

	position = _loop_center + Vector2(cos(_loop_angle), sin(_loop_angle)) * loop_radius
	var tangent := Vector2(sin(_loop_angle), -cos(_loop_angle))
	rotation = tangent.angle()

	if _loop_swept >= PI * 1.5:                # 270°
		position = Vector2(_flight_x, _flight_y)
		rotation = 0.0
		_bob_time = 0.0
		state = State.FLYING
		returned_to_flight.emit()


# ══════════════════════════════════════════════════════════════
#  TRAÎNÉE DE PARTICULES
# ══════════════════════════════════════════════════════════════
#
#  Petits ronds blancs semi-transparents qui rétrécissent
#  et s'effacent. local_coords = false → les particules
#  restent en place dans le monde et forment un sillage.
#
func _create_trail() -> void:
	_trail = CPUParticles2D.new()
	_trail.z_index = -1
	_trail.position = Vector2(-20, 0)          # émission derrière l'avion
	add_child(_trail)

	_trail.emitting = true
	_trail.amount = 30
	_trail.lifetime = 0.5
	_trail.local_coords = false
	_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT

	# Pas de vélocité : les particules restent sur place
	_trail.direction = Vector2.ZERO
	_trail.spread = 180.0
	_trail.initial_velocity_min = 0.0
	_trail.initial_velocity_max = 0.0

	# Taille initiale
	_trail.scale_amount_min = 4.0
	_trail.scale_amount_max = 6.0

	# Courbe de taille : rétrécit jusqu'à 0
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 1.0))
	scale_curve.add_point(Vector2(1.0, 0.0))
	_trail.scale_amount_curve = scale_curve

	# Dégradé : blanc 50% → transparent
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 0.5))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	_trail.color_ramp = gradient

	# Texture ronde (cercle flou via gradient radial)
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
