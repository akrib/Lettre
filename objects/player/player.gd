extends CharacterBody2D

signal dive_landed
signal returned_to_flight

enum State { FLYING, DIVE_LOOP, DIVING_DOWN, HIDDEN, RISING, RISE_LOOP }

@export var loop_radius: float = 120.0
@export var loop_speed: float = 3.5
@export var dive_speed: float = 700.0
@export var rise_speed: float = 700.0
@export var bob_amplitude: float = 4.0
@export var bob_frequency: float = 0.4
@export var bob_x_amplitude: float = 2.0
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

# ── Rainbow trail (Line2D) ──
var _trail_node: Node2D


func _ready() -> void:
	_flight_y = position.y
	_flight_x = position.x
	_create_rainbow_trail()


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


# ── Vol normal (balancement doux et lent) ────────────────────
func _process_flying(delta: float) -> void:
	_bob_time += delta

	var wave_y := sin(_bob_time * bob_frequency * TAU)
	var wave_x := sin(_bob_time * bob_x_frequency * TAU + 1.2)

	position.y = _flight_y + wave_y * bob_amplitude
	position.x = _flight_x + wave_x * bob_x_amplitude

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
#  PLONGEON
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
		if _trail_node:
			_trail_node.set_emitting(false)
		dive_landed.emit()


# ══════════════════════════════════════════════════════════════
#  REMONTÉE
# ══════════════════════════════════════════════════════════════
func resume_flight() -> void:
	_rise_target = Vector2(_flight_x + loop_radius, _flight_y - loop_radius)
	position = Vector2(_rise_target.x, get_viewport_rect().size.y + 150)
	rotation = -PI / 2.0
	visible = true
	if _trail_node:
		_trail_node.clear_trail()
		_trail_node.set_emitting(true)
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
#  TRAÎNÉE ARC-EN-CIEL (Line2D)
# ══════════════════════════════════════════════════════════════
func _create_rainbow_trail() -> void:
	var trail_scene := preload("res://objects/player/rainbow_trail.tscn")
	_trail_node = trail_scene.instantiate()
	# Le trail est enfant de l'avion, mais ses Line2D sont top_level
	# donc les points restent en place dans le monde
	_trail_node.position = Vector2(-20, 0)
	add_child(_trail_node)
