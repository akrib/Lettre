extends Node2D
## Effet de vent : lignes/particules horizontales qui traversent l'écran
## pour donner une sensation de vitesse.

var _wind_lines: CPUParticles2D
var _wind_dots: CPUParticles2D


func _ready() -> void:
	_create_wind_lines()
	_create_wind_dots()


func _process(_delta: float) -> void:
	# Ajuster la vitesse des particules au time_scale
	var ts: float = Global.time_scale
	_wind_lines.speed_scale = ts
	_wind_dots.speed_scale = ts


## Longues lignes de vent horizontales
func _create_wind_lines() -> void:
	_wind_lines = CPUParticles2D.new()
	_wind_lines.z_index = 2
	_wind_lines.position = Vector2(1200, 300)  # spawn à droite
	add_child(_wind_lines)

	_wind_lines.emitting = true
	_wind_lines.amount = 12
	_wind_lines.lifetime = 2.5
	_wind_lines.local_coords = false

	# Émission sur toute la hauteur
	_wind_lines.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_wind_lines.emission_rect_extents = Vector2(50, 320)

	# Direction vers la gauche
	_wind_lines.direction = Vector2(-1, 0)
	_wind_lines.spread = 5.0
	_wind_lines.initial_velocity_min = 250.0
	_wind_lines.initial_velocity_max = 450.0

	_wind_lines.gravity = Vector2.ZERO

	# Taille allongée (simuler des lignes)
	_wind_lines.scale_amount_min = 1.0
	_wind_lines.scale_amount_max = 2.0

	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.2))
	scale_curve.add_point(Vector2(0.3, 1.0))
	scale_curve.add_point(Vector2(0.7, 1.0))
	scale_curve.add_point(Vector2(1.0, 0.0))
	_wind_lines.scale_amount_curve = scale_curve

	# Couleur blanche semi-transparente
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	gradient.colors = PackedColorArray([
		Color(1, 1, 1, 0.0),
		Color(1, 1, 1, 0.15),
		Color(1, 1, 1, 0.12),
		Color(1, 1, 1, 0.0),
	])
	_wind_lines.color_ramp = gradient

	# Texture allongée horizontalement (trait)
	var tex := GradientTexture2D.new()
	var line_grad := Gradient.new()
	line_grad.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	line_grad.colors = PackedColorArray([
		Color.TRANSPARENT,
		Color.WHITE,
		Color.WHITE,
		Color.TRANSPARENT,
	])
	tex.gradient = line_grad
	tex.width = 64
	tex.height = 5
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0, 0.5)
	tex.fill_to = Vector2(1, 0.5)
	_wind_lines.texture = tex


## Petits points de vent (poussière)
func _create_wind_dots() -> void:
	_wind_dots = CPUParticles2D.new()
	_wind_dots.z_index = 1
	_wind_dots.position = Vector2(1200, 300)
	add_child(_wind_dots)

	_wind_dots.emitting = true
	_wind_dots.amount = 18
	_wind_dots.lifetime = 3.0
	_wind_dots.local_coords = false

	_wind_dots.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_wind_dots.emission_rect_extents = Vector2(30, 340)

	_wind_dots.direction = Vector2(-1, 0.1)
	_wind_dots.spread = 12.0
	_wind_dots.initial_velocity_min = 120.0
	_wind_dots.initial_velocity_max = 280.0

	_wind_dots.gravity = Vector2(0, 3)

	_wind_dots.scale_amount_min = 1.0
	_wind_dots.scale_amount_max = 2.5

	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))
	scale_curve.add_point(Vector2(0.2, 1.0))
	scale_curve.add_point(Vector2(0.8, 0.8))
	scale_curve.add_point(Vector2(1.0, 0.0))
	_wind_dots.scale_amount_curve = scale_curve

	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	gradient.colors = PackedColorArray([
		Color(1, 1, 1, 0.0),
		Color(1, 1, 1, 0.10),
		Color(1, 1, 1, 0.08),
		Color(1, 1, 1, 0.0),
	])
	_wind_dots.color_ramp = gradient

	# Texture ronde petite
	var tex := GradientTexture2D.new()
	var circle_grad := Gradient.new()
	circle_grad.set_color(0, Color.WHITE)
	circle_grad.set_color(1, Color.TRANSPARENT)
	tex.gradient = circle_grad
	tex.width = 8
	tex.height = 8
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	_wind_dots.texture = tex
