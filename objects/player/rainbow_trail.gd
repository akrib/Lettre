extends Node2D
## Traînée arc-en-ciel utilisant des Line2D en top_level.
## Chaque Line2D a une couleur du spectre et les points sont ajoutés
## à la global_position du parent chaque frame.
## En vol, les points existants sont décalés vers la gauche pour simuler
## l'éloignement dû au scroll de la scène.
## Inspiré de https://github.com/khalidabuhakmeh/godot-rainbow-trails

@export var max_points: int = 180
@export var trail_width: float = 12.0
@export var emitting: bool = true

var lines: Array[Line2D] = []

# Couleurs arc-en-ciel
var rainbow_colors: Array[Color] = [
	Color(0.55, 0.15, 0.90, 0.55),  # violet
	Color(0.25, 0.25, 1.0, 0.60),   # indigo
	Color(0.20, 0.60, 1.0, 0.65),   # bleu
	Color(0.15, 0.85, 0.40, 0.65),  # vert
	Color(1.0, 0.95, 0.20, 0.65),   # jaune
	Color(1.0, 0.55, 0.10, 0.60),   # orange
	Color(1.0, 0.20, 0.20, 0.55),   # rouge
]


func _ready() -> void:
	_create_lines()


func _create_lines() -> void:
	var count := rainbow_colors.size()

	for i in range(count):
		var line := Line2D.new()
		line.top_level = true
		line.z_index = -1

		var t := float(i) / float(count - 1)
		line.width = trail_width * (1.0 - t * 0.5)
		line.default_color = rainbow_colors[i]

		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.antialiased = true

		var width_curve := Curve.new()
		width_curve.add_point(Vector2(0.0, 1.0))
		width_curve.add_point(Vector2(0.5, 0.7))
		width_curve.add_point(Vector2(1.0, 0.0))
		line.width_curve = width_curve

		line.clear_points()
		add_child(line)
		lines.append(line)


func _physics_process(delta: float) -> void:
	if not emitting:
		_shrink_lines()
		return

	# ── Simuler l'éloignement en vol ──
	# L'avion ne bouge presque pas en vol mais la scène défile.
	# On décale tous les points existants vers la gauche pour que
	# la traînée s'étire derrière comme si l'avion avançait vite.
	var scroll_shift := Global.scroll_speed * Global.time_scale * delta
	if scroll_shift > 0.0:
		_shift_all_points(Vector2(-scroll_shift, 0.0))

	# ── Ajouter le nouveau point ──
	var point := global_position
	for i in range(lines.size()):
		var line := lines[i]
		var offset := Vector2(0, (i - lines.size() * 0.5) * 1.8)
		line.add_point(point + offset)
		if line.points.size() > max_points:
			line.remove_point(0)


## Décale tous les points existants d'un vecteur donné.
## Crée l'illusion que la traînée reste en place dans le monde
## pendant que l'avion "avance".
func _shift_all_points(offset: Vector2) -> void:
	for line in lines:
		var pts := line.points
		for j in range(pts.size()):
			pts[j] += offset
		line.points = pts


func _shrink_lines() -> void:
	for line in lines:
		if line.points.size() > 0:
			line.remove_point(0)


func clear_trail() -> void:
	for line in lines:
		line.clear_points()


func set_emitting(value: bool) -> void:
	emitting = value
