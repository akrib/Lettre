extends Node2D

signal event_zone_entered(event_index: int)

@export var scroll_speed: float = 80.0
@export var marker_spacing: float = 700.0
@export var timeline_y: float = 570.0
@export var bar_height: float = 60.0
@export var sign_width: float = 120.0
@export var sign_height: float = 36.0
@export var post_height: float = 40.0

## Combien de marqueurs charger en avance devant l'écran
@export var load_ahead: int = 3

var _scrolling := true
var _active_event_index: int = -1

# ── Gestion lazy load ──
var _markers: Array[Node2D] = []
var _loaded: Array[bool] = []
var _unloaded: Array[bool] = []

var _screen_width: float = 1152.0
var _screen_height: float = 648.0

# ── Shader fondu bords pour les vignettes ──
var _vignette_shader: Shader

# Couleurs
var _sign_bg := Color(0.15, 0.22, 0.35, 0.92)
var _sign_border := Color(0.85, 0.85, 0.85, 0.8)
var _bar_colors: Array[Color] = [
	Color(0.25, 0.45, 0.65, 0.7),
	Color(0.35, 0.30, 0.60, 0.7),
	Color(0.20, 0.50, 0.45, 0.7),
	Color(0.50, 0.35, 0.55, 0.7),
	Color(0.30, 0.55, 0.40, 0.7),
	Color(0.45, 0.40, 0.30, 0.7),
	Color(0.35, 0.50, 0.60, 0.7),
]
var _bar_active_color := Color(0.5, 0.75, 1.0, 0.8)
var _bar_seen_color := Color(0.45, 0.65, 0.4, 0.65)
var _post_color := Color(0.7, 0.7, 0.7, 0.5)
var _title_color := Color(1, 1, 1, 0.85)


func _ready() -> void:
	Global.scroll_speed = scroll_speed
	_screen_width = get_viewport_rect().size.x
	_screen_height = get_viewport_rect().size.y
	_create_vignette_shader()
	_create_placeholders()
	_update_loading()


func _process(delta: float) -> void:
	if not _scrolling or Global.is_paused:
		return

	var speed := scroll_speed * Global.time_scale * delta
	for marker in _markers:
		marker.position.x -= speed

	_check_active_zone()
	_update_loading()


# ══════════════════════════════════════════════════════════════
#  SHADER FONDU BORDS (vignettes)
# ══════════════════════════════════════════════════════════════

func _create_vignette_shader() -> void:
	_vignette_shader = Shader.new()
	_vignette_shader.code = """shader_type canvas_item;
uniform float fade_size : hint_range(0.0, 0.5) = 0.15;
void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float fx = smoothstep(0.0, fade_size, UV.x) * smoothstep(0.0, fade_size, 1.0 - UV.x);
	float fy = smoothstep(0.0, fade_size, UV.y) * smoothstep(0.0, fade_size, 1.0 - UV.y);
	col.a *= fx * fy;
	COLOR = col;
}
"""


# ══════════════════════════════════════════════════════════════
#  PLACEHOLDERS
# ══════════════════════════════════════════════════════════════

func _create_placeholders() -> void:
	var events: Array = Global.timeline_events
	for i in range(events.size()):
		var marker := Node2D.new()
		marker.position = Vector2(400 + i * marker_spacing, 0)
		marker.name = "Marker_%d" % i
		add_child(marker)
		_markers.append(marker)
		_loaded.append(false)
		_unloaded.append(false)


# ══════════════════════════════════════════════════════════════
#  SMART LOADING / UNLOADING
# ══════════════════════════════════════════════════════════════

func _update_loading() -> void:
	for i in range(_markers.size()):
		var marker_x: float = _markers[i].position.x
		var marker_right: float = marker_x + marker_spacing

		# ── UNLOAD : complètement sorti à gauche ──
		if marker_right < -200.0:
			if _loaded[i] and not _unloaded[i]:
				_unload_marker(i)
			continue

		# ── LOAD : dans la zone visible + load_ahead ──
		var load_boundary: float = _screen_width + load_ahead * marker_spacing
		if marker_x < load_boundary:
			if not _loaded[i] and not _unloaded[i]:
				_load_marker(i)


## Construit tous les visuels d'un marqueur
func _load_marker(index: int) -> void:
	var marker := _markers[index]
	var events: Array = Global.timeline_events
	var ev: Dictionary = events[index]

	# Barre de fond
	_add_timeline_bar(marker, index)

	# Vignette souvenir (grande image floutée derrière l'avion)
	_add_vignette(marker, ev, index, _screen_height)

	# Panneaux de dates
	var date_start: String = ev.get("date", "")
	_add_sign_post(marker, 0.0, date_start, true)

	var date_end: String = ""
	if index + 1 < events.size():
		date_end = events[index + 1].get("date", "")
	else:
		date_end = ev.get("date_end", "Aujourd'hui")
	_add_sign_post(marker, marker_spacing, date_end, false)

	# Titre
	_add_title(marker, ev.get("title", ""), index)

	_loaded[index] = true


## Libère tous les enfants visuels d'un marqueur
func _unload_marker(index: int) -> void:
	var marker := _markers[index]
	for child in marker.get_children():
		child.queue_free()
	_unloaded[index] = true


# ══════════════════════════════════════════════════════════════
#  VIGNETTE SOUVENIR
#  Première photo de l'événement (__1.jpg / __1.png),
#  50% de sa taille, 50% alpha, max 300h / 400w,
#  dans les 2/3 supérieurs, derrière l'avion (z_index -5)
# ══════════════════════════════════════════════════════════════

func _add_vignette(parent: Node2D, ev: Dictionary, _index: int, viewport_h: float) -> void:
	var photos: Array = ev.get("photos", [])
	if photos.is_empty():
		return

	var photo_path: String = photos[0]
	if not ResourceLoader.exists(photo_path):
		return

	var texture := load(photo_path) as Texture2D
	if not texture:
		return

	var tex_w: float = texture.get_width()
	var tex_h: float = texture.get_height()

	# Calcul 1 : contrainte hauteur max 300
	var scale_by_h: float = minf(300.0 / tex_h, 0.5)
	var area_h: float = (tex_w * scale_by_h) * (tex_h * scale_by_h)

	# Calcul 2 : contrainte largeur max 400
	var scale_by_w: float = minf(400.0 / tex_w, 0.5)
	var area_w: float = (tex_w * scale_by_w) * (tex_h * scale_by_w)

	# Choisir le scale qui donne la plus grande aire affichée
	var final_scale: float = scale_by_h if area_h >= area_w else scale_by_w

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(final_scale, final_scale)
	sprite.modulate = Color(1, 1, 1, 0.5)
	sprite.z_index = -8

	# Position aléatoire dans les 2/3 supérieurs
	var min_y: float = viewport_h * 0.10
	var max_y: float = viewport_h * 0.20
	var random_y: float = randf_range(min_y, max_y)

	sprite.position = Vector2(
		marker_spacing * 0.5,
		random_y + (tex_h * final_scale * 0.5)
	)

	# Shader fondu sur les bords
	var mat := ShaderMaterial.new()
	mat.shader = _vignette_shader
	mat.set_shader_parameter("fade_size", 0.15)
	sprite.material = mat

	parent.add_child(sprite)


# ══════════════════════════════════════════════════════════════
#  CONSTRUCTION VISUELLE
# ══════════════════════════════════════════════════════════════

func _add_timeline_bar(parent: Node2D, index: int) -> void:
	var bar := ColorRect.new()
	bar.position = Vector2(0, timeline_y - bar_height)
	bar.size = Vector2(marker_spacing, bar_height)
	bar.color = _bar_colors[index % _bar_colors.size()]
	bar.name = "Bar"
	parent.add_child(bar)

	var sep := ColorRect.new()
	sep.size = Vector2(2, bar_height)
	sep.position = Vector2(0, timeline_y - bar_height)
	sep.color = Color(1, 1, 1, 0.25)
	parent.add_child(sep)


func _add_sign_post(parent: Node2D, x_pos: float, date_text: String, is_left: bool) -> void:
	var sign_x := x_pos - sign_width * 0.5
	var sign_bottom := timeline_y - bar_height

	var post := ColorRect.new()
	post.size = Vector2(3, post_height)
	post.position = Vector2(x_pos - 1.5, sign_bottom - post_height)
	post.color = _post_color
	parent.add_child(post)

	var panel_y := sign_bottom - post_height - sign_height - 2
	var bg := ColorRect.new()
	bg.size = Vector2(sign_width, sign_height)
	bg.position = Vector2(sign_x, panel_y)
	bg.color = _sign_bg
	parent.add_child(bg)

	var bw := 2.0
	for edge in [
		[Vector2(sign_x, panel_y), Vector2(sign_width, bw)],
		[Vector2(sign_x, panel_y + sign_height - bw), Vector2(sign_width, bw)],
		[Vector2(sign_x, panel_y), Vector2(bw, sign_height)],
		[Vector2(sign_x + sign_width - bw, panel_y), Vector2(bw, sign_height)],
	]:
		var r := ColorRect.new()
		r.position = edge[0]
		r.size = edge[1]
		r.color = _sign_border
		parent.add_child(r)

	var lbl := Label.new()
	if is_left:
		lbl.text = "" + date_text
	else:
		lbl.text = date_text + ""
	lbl.position = Vector2(sign_x + 6, panel_y + 2)
	lbl.size = Vector2(sign_width - 12, sign_height - 4)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	lbl.add_theme_constant_override("shadow_outline_size", 2)
	parent.add_child(lbl)


func _add_title(parent: Node2D, title_text: String, _index: int) -> void:
	var lbl := Label.new()
	lbl.text = title_text
	lbl.name = "Title"

	var label_w := marker_spacing * 0.7
	lbl.position = Vector2(
		marker_spacing * 0.5 - label_w * 0.5,
		timeline_y - bar_height * 0.5 - 12
	)
	lbl.size = Vector2(label_w, 24)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", _title_color)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	lbl.add_theme_constant_override("shadow_outline_size", 3)
	parent.add_child(lbl)


# ══════════════════════════════════════════════════════════════
#  LOGIQUE
# ══════════════════════════════════════════════════════════════

func _check_active_zone() -> void:
	var player_x: float = 300.0
	if Global.player:
		player_x = Global.player.position.x

	var closest_idx := -1
	var closest_dist := 9999.0

	for i in range(_markers.size()):
		var left_x: float = _markers[i].position.x
		var right_x: float = left_x + marker_spacing

		if player_x >= left_x and player_x <= right_x:
			var dist := absf(left_x + marker_spacing * 0.5 - player_x)
			if dist < closest_dist:
				closest_dist = dist
				closest_idx = i

	if closest_idx != _active_event_index and closest_idx >= 0:
		_active_event_index = closest_idx
		event_zone_entered.emit(_active_event_index)
		_highlight_active_bar()


func _highlight_active_bar() -> void:
	for i in range(_markers.size()):
		if not _loaded[i] or _unloaded[i]:
			continue
		var bar: ColorRect = _markers[i].get_node_or_null("Bar")
		if not bar:
			continue
		if i == _active_event_index:
			bar.color = _bar_active_color
		elif Global.is_event_seen(i):
			bar.color = _bar_seen_color
		else:
			bar.color = _bar_colors[i % _bar_colors.size()]


func get_active_event() -> Dictionary:
	if _active_event_index < 0 or _active_event_index >= Global.timeline_events.size():
		return {}
	return Global.timeline_events[_active_event_index]


func get_active_event_index() -> int:
	return _active_event_index


func pause() -> void:
	_scrolling = false


func resume() -> void:
	_scrolling = true
